#!/bin/bash

if test -f $cache_file; then
   use_cache=y
   clear
   echo
   echo "Use these cached settings: "
   echo
   cat $cache_file
   echo
   read -p 'Ok [Y/n]: ' use_cache
   if test ! "x$use_cache" = "xn"; then
      . $cache_file
      return
   else
      rm -f $cache_file
   fi
fi

clear
echo
echo "Which compiler you want to use to compile the external packages?"
PS3='Please enter a choice from the above menu: '

select CHOICE in "GCC (Linux, and older versions of Mac OSX)" "Intel Compiler (Linux)" "CC (Solaris)" "Portland Compiler" "Clang (Mac OSX)" Quit
do
  case "$CHOICE" in
               Quit) exit
                     ;;
              "GCC (Linux, and older versions of Mac OSX)")
                     compiler=gcc
                     break
                     ;;
               "Intel Compiler (Linux)")
                     compiler=intel
                     break
                     ;;
                "CC (Solaris)")
                     compiler=CC
                     break
                     ;;
                "Portland Compiler")
                     compiler=PGI
                     break
                     ;;
                "Clang (Mac OSX)")
                     compiler=Clang
                     break
                     ;;
                 "") echo This value is not valid. Hit Enter to see menu again!
                     continue
                     ;;
   esac
done

clear
echo
echo "Do you want to compile the external packages with or without debug"
echo "information or with optimization?"
PS3='Please enter a choice from the above menu: '

select CHOICE in "No Debug Info" "Debug Info" "Optimize" "Optimize with Debug Info" Quit
do
  case "$CHOICE" in
                      Quit) exit
                            ;;
           "No Debug Info") debug=no
                            optimize=no
                            break
                            ;;
              "Debug Info") debug=yes
                            optimize=no
                            break
                            ;;
                "Optimize") debug=no
                            optimize=yes
                            break
                            ;;
"Optimize with Debug Info") debug=yes
                            optimize=yes
                            break
                            ;;
                        "") echo This value is not valid. Hit Enter to see menu again!
                            continue
                            ;;
   esac
done

clear
echo
echo "Would you like to install FairMQ Only?"
echo "Choosing 'Yes' will skip building ROOT, GEANT, etc"
echo "The default option is 'No' "
PS3='Please enter a choice from the above menu: '

select CHOICE in "Yes" "No" "FairMQ dependencies only" Quit
do
case "$CHOICE" in
Quit) exit
      ;;
"Yes") build_MQOnly=yes
       break
       ;;
"No")  build_MQOnly=no
       break
       ;;
"FairMQ dependencies only") build_MQOnly=depsonly
                            break
                            ;;
"") echo This value is not valid. Hit Enter to see menu again!
continue
;;
esac
done

clear

if [ "$build_MQOnly" = "no" ]
then
    echo "ROOT 6 will be build"
    echo

    build_root6=yes

    echo
    echo "Would you like to install Simulation engines and event generators?"
    PS3='Please enter a choice from the above menu: '

    select CHOICE in "Yes" "No" Quit
    do
    case "$CHOICE" in
    Quit) exit
    ;;
    "Yes") install_sim=yes
    break
    ;;
    "No")  install_sim=no
    break
    ;;
    "") echo This value is not valid. Hit Enter to see menu again!
    continue
    ;;
    esac
    done
else
    install_sim=no
fi


if [ "$install_sim" = "yes" ]
then
    clear
    echo
    echo "Would you like to install the additionally available data files"
    echo "for the Geant4 package?"
    echo "To do so you either need an internet conection (Internet) or you"
    echo "have to provide the files in the transport subdirectory (Directory)."
    PS3='Please enter a choice from the above menu: '

    select CHOICE in "Don't install" "Internet" "Directory" Quit
    do
      case "$CHOICE" in
                  Quit) exit
                        ;;
       "Don't install") geant4_download_install_data_automatic=no
                geant4_install_data_from_dir=no
                        break
                        ;;
          "Internet")   geant4_download_install_data_automatic=yes
                        geant4_install_data_from_dir=no
                        break
                        ;;
           "Directory") geant4_download_install_data_automatic=no
                        geant4_install_data_from_dir=yes
                        break
                        ;;
                    "") echo This value is not valid. Hit Enter to see menu again!
                        continue
                        ;;
       esac
    done
else
  geant4_download_install_data_automatic=no
  geant4_install_data_from_dir=no
fi


if [ "$install_sim" = "yes" ]
then
    clear
    echo
    echo "Would you like to compile Geant4 in multihreaded mode?"
    echo "For that to work all detectors have to impliment CloneModule "
    PS3='Please enter a choice from the above menu: '

    select CHOICE in "Yes" "No" Quit
    do
      case "$CHOICE" in
            Quit) exit
            ;;
      "Yes") geant4mt=yes
            break
            ;;
      "No")  geant4mt=no
            break
            ;;
      "") echo This value is not valid. Hit Enter to see menu again!
            continue
            ;;
   esac
   done
 else
      geant4mt=no
 fi


clear


if [ "$build_MQOnly" = "no" ]
then
     echo
     echo "Would you like to install the python bindings for ROOT and Geant4 (only if simulation engines are installed)"
     PS3='Please enter a choice from the above menu: '

     select CHOICE in "Yes" "No" Quit
     do
       case "$CHOICE" in
                   Quit) exit
                         ;;
                  "Yes") build_python=yes
                         break
                         ;;
                   "No") build_python=no
                         break
                         ;;
                     "") echo This value is not valid. Hit Enter to see menu again!
                         continue
                            ;;
       esac
     done
fi

clear

question=true
writable_dir=true
while $question; do
  clear
  if ! $writable_dir; then
    echo "You don't have write permissions for $SIMPATH_INSTALL"
  fi
  echo 'Please define a directory for the installation of the external packages.'
  echo 'An installation in the source directory is not possible any longer.'
  echo 'Please enter the full path of the installation directory'
  echo ''
  read -p 'path: ' SIMPATH_INSTALL
  clear
    # expand variables, which could be in the filepath. A example is if $PWD is in the path
  eval SIMPATH_INSTALL=$SIMPATH_INSTALL
  echo "Is $SIMPATH_INSTALL the correct path?"
  PS3='Please enter a choice from the above menu: '

  select CHOICE in "No" "Yes" Quit
  do
  case "$CHOICE" in
      Quit) exit
          ;;
      "No") question=true
          break
          ;;
      "Yes") question=false
          break
          ;;
      "" ) echo This value is not valid. Hit Enter to see menu again!
          continue
          ;;
  esac
  done
    #check if the user can write to the installation path
  mkdir -p $SIMPATH_INSTALL
  if [ $? -ne 0 ]; then
      question=true
      writable_dir=false
  fi
done
