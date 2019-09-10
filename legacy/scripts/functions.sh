#!/bin/bash
# define functions needed later on

#_____________________________________________________________________
# checks if one of the files is existing and print message
# updated to check a list of packages because some libraries
# have slightly different names on differnt platforms
function not_there {
    pack=$1
    shift
    files=$*
    retval=0
    for file in $files;do
      if [ -e $file ];
      then
        echo "*** Package $pack is OK ***" | tee -a $logfile
        return 1
      fi
    done

    echo "*** Compiling $pack ................ " | tee -a $logfile
    return 0
}

#_____________________________________________________________________
# check if package is already unpacked and do the unpacking if
# necessary
function untar {
    pack=$1
    tarf=$2
    if [ -d $pack ];
    then
       echo "*** Package $pack already unpacked ***" | tee -a $logfile
    else
       echo "*** Unpacking $tarf .............." | tee -a $logfile
       if [ "$platform" != "solaris" ];
       then
         if [ "$(file $tarf | grep -c gzip)" = "1" ];
         then
           tar zxf $tarf
         elif [ "$(file $tarf | grep -c bzip2)" = "1" ];
         then
           tar xjf $tarf
         elif [ "$(file $tarf | grep -c Zip)" = "1" ];
         then
           unzip $tarf
         else
	   echo "--E-- Cannot unpack package $pack"
           exit
         fi
       else
         if [ "$(file $tarf | grep -c gzip)" = "1" ];
         then
            /usr/sfw/bin/gtar xzf $tarf
         elif [ "$(file $tarf | grep -c bzip2)" = "1" ];
         then
            /usr/sfw/bin/gtar xjf $tarf
         else
	   echo "--E-- Cannot unpack package $pack"
           exit
         fi
       fi
    fi
}

#_____________________________________________________________________
# check if file exists after the compilation process
# return error code
function check_success {
    pack=$1
    file=$2
    if [ -e $file ];
    then
      echo "*** $1 compiled successfully ***" | tee -a $logfile
      return 1
    else
      echo "*** ERROR: $1 could not be created." | tee -a $logfile
      return 0
    fi
}

#_____________________________________________________________________
# function to do the patching. This should avoid problems with applying
# the same patch again. In each package directory a apllied_patches.txt
# file is created and the information about the aplied patches is
# saved. When runing the script again it is checked if the patch
# was already aplied. If this is the case no action is taken, else
# the patch is applied
function mypatch {
  patch_full_file=$1
  patch_file=$(basename "$patch_full_file")
  if [ ! -e applied_patches.txt ]; then
    patch -p0 < $patch_full_file
    echo $patch_file >> applied_patches.txt
  else
    if [ "$(grep -c $patch_file applied_patches.txt )" = "1" ]; then
      echo "The patch $patch_file is already applied."
    else
      patch -p0 < $patch_full_file
      echo $patch_file >> applied_patches.txt
    fi
  fi
}

#_____________________________________________________________________
# function perform sed command differently on linux and on Mac Os X
# return error code
# first parameter is the text to search for, the second is the
# replacement and the third one defines the filename
# with the fourth on defines if the the string
# contains a /
function mysed {

    # Assert that we got enough arguments
    if [ $# -lt 3 ];
    then
      echo "mysed: 3 or 4 arguments needed"
      echo "Script was called only with $# arguments"
      echo "Searchstring: $1"
      echo "Replacement : $2"
      echo "Filename    : $3"
      if [ $# -eq 4 ];
      then
        echo "Option    : $4"
      fi
      return 1
    fi

    old=$1
    new=$2
    change_file=$3
    if [ $# -eq 4 ];
    then
      has_slash=yes
    fi


   if [ "$platform" = "linux" ];
    then
      if [ "$has_slash" = "yes" ];
      then
        sed -e "s#$old#$new#g" -i'' $change_file
      else
        sed -e "s/$old/$new/g" -i'' $change_file
      fi
    elif [ "$platform" = "macosx" ];
    then
      if [ "$has_slash" = "yes" ];
      then
        sed -e "s#$old#$new#g" -i '' $change_file
      else
        sed -e "s/$old/$new/g" -i '' $change_file
      fi
    elif [ "$platform" = "solaris" ];
    then
      mv $change_file tmpfile
      if [ "$has_slash" = "yes" ];
      then
        sed -e "s#$old#$new#g" tmpfile > $change_file
      else
        sed -e "s/$old/$new/g" tmpfile > $change_file
      fi
      rm tmpfile
    fi
}

#_____________________________________________________________________
# The function checks if all needed variables are defined in the input file and
# if only valid values and value combinations are present in the input file.
function check_variables {

  if [ "$compiler" = "" ]; then
    echo "*** The compiler definition is not set in the input file."
    echo "*** Please add the compiler definition in the input file."
    echo "*** e.g.: compiler=gcc"
    echo "*** possible values are gcc, Clang, intel" # CC, PGI
    exit 1
  else
    if [ ! "$compiler" = "gcc" -a ! "$compiler" = "Clang" -a ! "$compiler" = "intel" ]; then
      echo "*** The compiler definition $compiler is not known."
      echo "*** possible values are gcc, Clang, intel" # CC, PGI
      echo "*** Please correct the compiler definition in the input file."
      echo "*** e.g.: compiler=gcc"
      exit 1
    fi
  fi
  if [ "$debug" = "" ]; then
    echo "*** The debug definition is not set in the input file."
    echo "*** Please add the debug definition in the input file."
    echo "*** e.g.: debug=no or debug=yes"
    exit 1
  else
    check_yes_no debug
  fi
  if [ "$optimize" = "" ]; then
    echo "*** The optimize definition is not set in the input file."
    echo "*** Please add the optimize definition in the input file."
    echo "*** e.g.: optimize=no or optimize=yes"
    exit 1
  else
    check_yes_no optimize
  fi
  if [ "$geant4_download_install_data_automatic" = "" ]; then
    echo "*** It is not defined in the input file if the geant4 data should be downloaded automatically."
    echo "*** Please add the missing definition in the input file."
    echo "*** e.g.: geant4_download_install_data_automatic=[no/yes]"
    exit 1
  else
    check_yes_no geant4_download_install_data_automatic
  fi
  if [ "$geant4_install_data_from_dir" = "" ]; then
    echo "*** It is not defined in the input file if the geant4 data should be installed from the directory."
    echo "*** Please add the missing definition in the input file."
    echo "*** e.g.: geant4_install_data_from_dir=[no/yes]"
    exit 1
  else
    check_yes_no geant4mt
  fi
  if [ "$geant4mt" = "" ]; then
    echo "*** It is not defined in the input file if the geant4 should be builb with MT or not."
    echo "*** Please add the missing definition in the input file."
    echo "*** e.g.: geant4mt=[no/yes]"
    exit 1
  else
    check_yes_no geant4_install_data_from_dir
  fi

  if [ "$build_python" = "" ]; then
    echo "*** It is not defined in the input file if the python bindings should be installed."
    echo "*** Please add the missing definition in the input file."
    echo "*** e.g.: build_python=[no/yes]"
    exit 1
  else
    check_yes_no build_python
  fi
  if [ "$build_root6" = "" ]; then
    echo "*** It is not defined in the input file if root6 should be installed."
    echo "*** Please add the missing definition in the input file."
    echo "*** e.g.: build_root6=[no/yes]"
    exit 1
  else
    check_yes_no build_root6
  fi
  if [ "$install_sim" = "" ]; then
    echo "*** It is not defined in the input file if all tools for simulation should be installed."
    echo "*** Please add the missing definition in the input file."
    echo "*** e.g.: install_sim=[no/yes]"
    exit 1
  else
    check_yes_no install_sim
  fi
  if [ "$build_MQOnly" = "" ]; then
    echo "*** It is not defined in the input file if only the FairMQ toolchain should be installed."
    echo "*** Please add the missing definition in the input file."
    echo "*** e.g.: build_MQOnly=[no/yes/depsonly]"
    exit 1
  else
    check_yes_no_depsonly build_MQOnly
  fi
  if [ "$SIMPATH_INSTALL" = "" ]; then
    echo "*** No installation directory is defined in the input file."
    echo "*** Please add the missing definition in the input file."
    echo "*** e.g.: SIMPATH_INSTALL=<installation directory>"
    exit 1
  else
    # expand variables, which could be in the filepath.
    # A example is if $PWD is in the path
    eval SIMPATH_INSTALL=$SIMPATH_INSTALL
    #check if the user can write to the installation path
    mkdir -p $SIMPATH_INSTALL
    if [ $? -ne 0 ]; then
      echo "Cannot write to the installation directory $SIMPATH_INSTALL."
      exit 1
    fi
  fi
  if [ "$geant4_download_install_data_automatic" = "yes" -a "$geant4_install_data_from_dir" = "yes" ]; then
    echo "*** The variables \"geant4_download_install_data_automatic\" and"
    echo "*** \"geant4_install_data_from_dir\" can't be set both to \"yes\" at the"
    echo "*** same time. All other combinations yes/no, no/no, and no/yes are valid."
    echo "*** Please change the definitions in the input file."
    exit 1
  fi

}

#_____________________________________________________________________
# The function checks if the varibale has either yes or no as value.
# In case any other value is given the script stops with an error message.
check_yes_no() {
  variable=$1
  eval value=\$$1 #eval forces update of $a which is set to the value of $1
  if [ ! "$value" = "yes" -a ! "$value" = "no" ]; then
    echo "*** For the variable $variable only yes or no are allowed."
    echo "*** Please correct the definition of \"$variable=$value\" in the input file."
    echo "*** e.g.: $variable=no or $variable=yes"
    exit 1
  fi
}

check_yes_no_depsonly() {
  variable=$1
  eval value=\$$1 #eval forces update of $a which is set to the value of $1
  if [ ! "$value" = "yes" -a ! "$value" = "no" -a ! "$value" = "depsonly" ]; then
    echo "*** For the variable $variable only yes/no/depsonly are allowed."
    echo "*** Please correct the definition of \"$variable=$value\" in the input file."
    echo "*** e.g.: $variable=no, $variable=yes or $variable=depsonly"
    exit 1
  fi
}

#_____________________________________________________________________
function is_in_path {
    # This function checks if a file exists in the $PATH.
    # To do so it uses which.
    # There are several versions of which available with different
    # return values. Either it is "" or "no searched program in PATH" or
    # "/usr/bin/which: no <searched file>".
    # To check for all differnt versions check if the return statement is
    # not "".
    # If it is not "" check if the return value starts with no or have
    # the string "no <searched file> in the return string. If so set
    # return value to "". So all negative return statements go to "".
    # If program is found in Path return 1, else return 0.

    searched_program=$1
    answer=$(which $searched_program)
    if [ "$answer" != "" ];
    then
      no_program=$(which $searched_program | grep -c '^no' )
      no_program1=$(which $searched_program | grep -c "^no $searched_program")
      if [ "$no_program" != "0" -o "$no_program1" != "0" ];
      then
        answer=""
      fi
    fi

    if [ "$answer" != "" ];
    then
      return 1
    else
      return 0
    fi
}

#_____________________________________________________________________
function create_links {

     # create symbolic links from files with suffix $2 to $1

      ext1=$1
      ext2=$2

      for file in $(ls *.$ext1);
      do
         if [ ! -L ${file%.*}.$ext2 ]; then
           ln -s $file ${file%.*}.$ext2
         fi
      done
}

#_____________________________________________________________________
function generate_config_cache {
  echo compiler=$compiler > $cache_file
  echo debug=$debug >> $cache_file
  echo optimize=$optimize >> $cache_file
  echo build_MQOnly=$build_MQOnly >> $cache_file
  echo geant4_download_install_data_automatic=$geant4_download_install_data_automatic >> $cache_file
  echo geant4_install_data_from_dir=$geant4_install_data_from_dir >> $cache_file
  echo geant4mt=$geant4mt >> $cache_file
  echo build_root6=$build_root6 >> $cache_file
  echo build_python=$build_python >> $cache_file
  echo install_sim=$install_sim >> $cache_file
  echo SIMPATH_INSTALL=$SIMPATH_INSTALL >> $cache_file
  echo platform=$platform >> $cache_file
}

#_____________________________________________________________________
function download_file {
      # download the file from the given location using either wget or
      # curl depending which one is available

      url=$1

      if [ "$install_curl" = "yes" ]; # no curl but wget
      then
        wget $url
      else
        # -L follow redirections which is needed for boost
        curl -O -L $url
      fi
}

function check_library {
    # The function is inspired by the ROOT configure script and adapted
    # to run on linux and Mac OS X
    #
    # This function will try to find out if a library [$1] contains 64 bit
    # or 32 bit code. Currently works only for linux and Mac OS X.
    # The result of the check is stored in lib_is, which should be
    # immediately copied or used , since the variable
    # will be overwritten at next invocation of this function.

    chklibname=$1

    lib_is=0

    # Assert that we got enough arguments
    if [ $# -ne 1 ];
    then
      echo "check_library: not 1 argument"
      return 1
    fi


    if [ "x`basename $chklibname .a`" != "x`basename $chklibname`" ]; then
        # we have an archive .a file
        if [ "$platform" = "linux" ];
        then
          objdump -a $1 | grep 'x86-64' > /dev/null 2>& 1
          ret=$?
        elif [ "$platform" = "macosx" ];
        then
          # 0xfeedfacf is the magic key for 64bit files
          otool -h $1 | grep '0xfeedfacf' > /dev/null 2>& 1
          ret=$?
        elif [ "$platform" = "solaris" ];
        then
          # Since I don't have a 64bit machine in can only test for 32bit
          # because i don't now the result on a 64bit machine.
          /usr/sfw/bin/gobjdump -a $1 | grep 'elf32-i386' > /dev/null 2>& 1
          ret1=$?
          if [ $ret1 -eq 0 ];
          then
            ret=1
          else
            ret=0
          fi
        fi
    else
        if [ "$platform" = "solaris" ];
        then
           file $1 | grep '64-Bit' > /dev/null 2>& 1
           ret=$?
           if [ $ret -eq 1 ];then
             file $1 | grep '64-bit' > /dev/null 2>& 1
             ret=$?
           fi
        else
           file -L $1 | grep '64-bit' > /dev/null 2>& 1
           ret=$?
        fi
    fi
    if [ $ret -eq 0 ];
    then
      lib_is=64bit
    else
      lib_is=32bit
    fi

}

function check_all_libraries {
    # This function loops over all libraries in the given path and
    # checks if the library contains code as given in $system.

    # Assert that we got enough arguments
    if [ $# -ne 1 ];
    then
      echo "check_all_libraries: not 1 argument"
      return 1
    fi

    chkdirname=$1
    echo "**** Checking libraries in $chkdirname ****" | tee -a $logfile_lib

    if [ "$platform" = "linux" -o "$platform" = "solaris" ];
     then
       shared_ext=so
     elif [ "$platform" = "macosx" ];
     then
       shared_ext=dylib
     fi

    oldpwd=$(pwd)
    cd $chkdirname
    if [ "$(find . -name "lib*.$shared_ext" | wc -l)" -ne 0 ];
    then
        for file in $(ls *.$shared_ext);
        do
          check_library $file
          if [ "$lib_is" != "$system" ];
              then
              echo "Library $file is $lib_is, but system is $system" | tee -a $logfile_lib
          fi
        done
    fi
    if [ "$(find . -name "lib*.a" | wc -l)" -ne "0" ];
    then
        for file in $(ls lib*.a);
          do
          check_library $file
          if [ "$lib_is" != "$system" ];
              then
              echo "Library $file is $lib_is, but system is $system" | tee -a $logfile_lib
          fi
        done
    fi
    cd $oldpwd
}

function create_installation_directories {
    # This function creates the defined installation directory
    # and all directories/links inside

    mkdir -p $SIMPATH_INSTALL/bin
    mkdir -p $SIMPATH_INSTALL/include
    mkdir -p $SIMPATH_INSTALL/lib
    mkdir -p $SIMPATH_INSTALL/share
    if [ ! -e $SIMPATH_INSTALL/lib64 ]; then
      ln -s $SIMPATH_INSTALL/lib $SIMPATH_INSTALL/lib64
    fi
}
