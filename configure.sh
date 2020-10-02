#!/bin/bash

function init_dialog() {
  DIALOG_OK=0
  DIALOG_CANCEL=1
  DIALOG_HELP=2
  DIALOG_EXTRA=3
  DIALOG_ITEM_HELP=4
  DIALOG_ESC=255
  W=70
  H=30
}

function dialog_default_handlers() {
  echo $1
  case $1 in
    $DIALOG_OK)
      echo "OK pressed. Not implemented."
      ;;
    $DIALOG_CANCEL)
      echo "Cancel pressed. Exiting."
      ;;
    $DIALOG_HELP)
      echo "Help pressed. Not implemented."
      ;;
    $DIALOG_EXTRA)
      echo "Extra button pressed. Not implemented."
      ;;
    $DIALOG_ITEM_HELP)
      echo "Item-help button pressed. Not implemented."
      ;;
    $DIALOG_ESC)
      echo "ESC pressed or error. Exiting. Result: ${result}"
      ;;
  esac
  exit 1
}

function check_cmd() {
  local cmd=$1
  local src=$2

  which $cmd > /dev/null

  if [ $? -ne 0 ]
  then
    echo "Error: command not found: $cmd"
    echo ""
    echo "Please install the $cmd command and run again:"
    echo ""
    echo "            macOS: brew install $cmd"
    echo "    Debian/Ubuntu: apt-get install $cmd"
    echo "           Fedora: dnf install $cmd"
    echo "  CentOS/OpenSuse: yum install $cmd"
    echo "           Source: $src"
    echo ""
  fi
}

function show_dialog() {
  exec 3>&1
  result=$(dialog --backtitle "FairSoft Configurator" "$@" 2>&1 1>&3)
  exec 3>&-
  clear
}

### sanity checks
check_cmd "dialog" "https://invisible-island.net/dialog/dialog.html"
check_cmd "cmake" "https://cmake.org/download/"
check_cmd "git" "https://git-scm.com/downloads"

### init
basedir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
init_dialog

### compiler
compiler="gcc"

show_dialog --title "Compiler" \
  --radiolist "Choose the compiler to compile the external packages:" 13 60 5 \
    gcc "GCC (Linux, and older versions of Mac OSX)" on \
    Clang "Clang (Mac OSX)" off \
    intel "Intel Compiler (Linux)" off \
    CC "CC (Solaris)" off \
    PGI "Portland Compiler" off

case $? in
  $DIALOG_OK) compiler=$result ;;
  *) dialog_default_handlers $? ;;
esac

### compile options
debug=yes
optimize=yes

show_dialog --title "Compile options" \
  --checklist "" 8 52 2 \
  debug "Enable debug information" on \
  optimize "Enable optimization" on

echo $result
case $? in
  $DIALOG_OK)
    res=($result)
    debug=no
    optimize=no
    for k in "${res[@]}"; do declare "${k}=yes"; done
    ;;
  *) dialog_default_handlers $? ;;
esac

### packages
packages=full

show_dialog --title "Packages" \
  --radiolist "Which set of external packages do you want to install?" 12 90 4 \
    full "All dependencies" on \
    lightweight "All except simulation engines and event generators" off \
    fairmq "FairMQ and dependencies only" off \
    fairmqdev "FairMQ development dependencies only" off

case $? in
  $DIALOG_OK) packages=$result ;;
  *) dialog_default_handlers $? ;;
esac

### package options
geant4mt=no
python=no

show_dialog --title "Package options" \
  --checklist "" 8 72 2 \
  geant4mt "Enable multi-threading in Geant4" off \
  python "Install Python binding for ROOT and Geant4" off

case $? in
  $DIALOG_OK)
    res=($result)
    for k in "${res[@]}"; do declare "${k}=yes"; done
    ;;
  *) dialog_default_handlers $? ;;
esac

### directories
version=$(git -C $basedir describe)
if [ -n "$HOME" ]
then
  builddir="${HOME}/fairsoft/${version}_build"
  installdir="${HOME}/fairsoft/${version}"
else
  builddir="${basedir}/build"
  installdir="${basedir}/install"
fi

show_dialog --title "Directories" \
  --form "Choose the following directories" 9 85 0 \
    "FairSoft version"      1 2 "$version"    1 24 0  0 \
    "Build dir"             2 2 "$builddir"   2 24 80 300 \
    "Install dir (SIMPATH)" 3 2 "$installdir" 3 24 80 300

case $? in
  $DIALOG_OK)
    res=($result)
    builddir=${res[0]}
    installdir=${res[1]}
    ;;
  *) dialog_default_handlers $? ;;
esac

### summary
show_dialog --title "Summary" --ok-label "Install" \
  --form "" 15 100 0 \
    "FairSoft version"      1 2 "$version"    1 24 0 0 \
    "Compiler"              2 2 "$compiler"   2 24 0 0 \
    "Debug info"            3 2 "$debug"      3 24 0 0 \
    "Optimize"              4 2 "$optimize"   4 24 0 0 \
    "Package set"           5 2 "$packages"   5 24 0 0 \
    "Multi-threaded Geant4" 6 2 "$geant4mt"   6 24 0 0 \
    "Python bindings"       7 2 "$python"     7 24 0 0 \
    "Build dir"             8 2 "$builddir"   8 24 0 0 \
    "Install dir (SIMPATH)" 9 2 "$installdir" 9 24 0 0

case $? in
  $DIALOG_OK) ;;
  *) dialog_default_handlers $? ;;
esac

### install
mkdir -p "$builddir"
pushd "$builddir"
cmake -D METHOD=LEGACY -D CMAKE_INSTALL_PREFIX="$(realpath $installdir)" "$(realpath $basedir)"
cmake --build .
