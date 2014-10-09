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
  if [ "$install_sim" = "" ]; then
    echo "*** It is not defined in the input file if all tools for simulation should be installed."
    echo "*** Please add the missing definition in the input file."
    echo "*** e.g.: install_sim=[no/yes]"
    exit 1
  else
    check_yes_no install_sim
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
  if [ "$debug" = "yes" -a "$optimize" = "yes" ]; then
    echo "*** The variables \"debug\" and \"otimize\" can't be set both to \"yes\" at the"
    echo "*** same time. All other combinations yes/no, no/no, and no/yes are valid."
    echo "*** Please change the definitions in the input file."
    exit 1 
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
         ln -s $file ${file%.*}.$ext2
      done

}

#_____________________________________________________________________
function generate_config_cache {
  echo compiler=$compiler > $cache_file
  echo debug=$debug >> $cache_file
  echo optimize=$optimize >> $cache_file
  echo geant4_download_install_data_automatic=$geant4_download_install_data_automatic >> $cache_file
  echo geant4_install_data_from_dir=$geant4_install_data_from_dir >> $cache_file
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
