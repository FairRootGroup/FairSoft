#!/bin/bash

function init_dialog() {
  DIALOG_OK=0
  DIALOG_CANCEL=1
  DIALOG_HELP=2
  DIALOG_EXTRA=3
  DIALOG_ITEM_HELP=4
  DIALOG_ESC=255
  export DIALOGRC="${basedir}/legacy/dialog.rc"
}

function dialog_default_handlers() {
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

  command -v $cmd &> /dev/null

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
    echo "Exiting now."
    exit 1
  fi
}

function show_dialog() {
  exec 3>&1
  result=$(dialog --backtitle "FairSoft Configurator" "$@" 2>&1 1>&3)
  ret=$?
  exec 3>&-
  clear
  return $ret
}

### sanity checks
check_cmd "curl" "https://curl.haxx.se/download.html"
check_cmd "dialog" "https://invisible-island.net/dialog/dialog.html"
check_cmd "git" "https://git-scm.com/downloads"

### init
basedir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ncpus="$(command -v nproc &> /dev/null && nproc --all || echo 4)"
init_dialog

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

if [ $packages == "full" ]
then
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
fi

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

show_dialog --title "Build options" \
  --form "Choose the following directories and amount of CPUs to use for parallel building:" 11 85 0 \
    "FairSoft version"      1 2 "$version"    1 24 0  0 \
    "Build dir"             2 2 "$builddir"   2 24 80 300 \
    "Install dir (SIMPATH)" 3 2 "$installdir" 3 24 80 300 \
    "#CPUs"                 4 2 "$ncpus"      4 24 3 3

case $? in
  $DIALOG_OK)
    res=($result)
    builddir=${res[0]}
    installdir=${res[1]}
    ncpus=${res[2]}
    ;;
  *) dialog_default_handlers $? ;;
esac

### summary
show_dialog --title "Summary" --ok-label "Configure" \
  --form "" 15 100 0 \
    "FairSoft version"      1 2 "$version"    1 24 0 0 \
    "Debug info"            2 2 "$debug"      2 24 0 0 \
    "Optimize"              3 2 "$optimize"   3 24 0 0 \
    "Package set"           4 2 "$packages"   4 24 0 0 \
    "Multi-threaded Geant4" 5 2 "$geant4mt"   5 24 0 0 \
    "Python bindings"       6 2 "$python"     6 24 0 0 \
    "Build dir"             7 2 "$builddir"   7 24 0 0 \
    "Install dir (SIMPATH)" 8 2 "$installdir" 8 24 0 0 \
    "#CPUs"                 9 2 "$ncpus"      9 24 0 0

case $? in
  $DIALOG_OK) ;;
  *) dialog_default_handlers $? ;;
esac

mkdir -p "$builddir"
mkdir -p "$installdir"

### bootstrap cmake if needed
too_old=1
required=3.16
if command -v cmake > /dev/null
then
  current=$(cmake --version | head -1 | cut -d' ' -f3)
  check="${required}\n${current}\n"
  printf $check | sort -V -C
  too_old=$?
fi

if [ $too_old -eq 1 ]
then
  cmakebaseurl="https://github.com/Kitware/CMake/releases/download/v"
  cmakeversion="3.18.3"

  show_dialog --title "Bootstrap CMake" \
    --yes-label "Yes, bootstrap !" \
    --no-label "Cancel, I will install myself" \
    --yesno "Did not find required CMake ${required}. Do you want to continue to \
bootstrap CMake ${cmakeversion} to ${installdir}?" 8 80

  case $? in
    $DIALOG_OK) ;;
    *) dialog_default_handlers $? ;;
  esac

  set -e
  pushd "$builddir"
  cmaketargz="cmake-${cmakeversion}-$(uname -s)-$(uname -m).tar.gz"
  curl -L -O "${cmakebaseurl}${cmakeversion}/$cmaketargz"
  cmakechecksums="cmake-${cmakeversion}-SHA-256.txt"
  curl -L -O "${cmakebaseurl}${cmakeversion}/$cmakechecksums"
  grep "$(uname -s).*$(uname -m).*\.tar\.gz" $cmakechecksums > checksum.txt
  sha256sum -c checksum.txt
  tar xf "$cmaketargz" -C "$installdir" --strip-components=1
  popd
  set +e
  cmake="${installdir}/bin/cmake"
else
  cmake=cmake
fi

### configure
(
set -x
$cmake -S "$basedir" -B "$builddir" \
  -DBUILD_METHOD=legacy \
  -DCMAKE_INSTALL_PREFIX="$installdir" \
  -DPACKAGES=$packages \
  -DNCPUS=$ncpus
)

echo ""
echo ""
echo ">>> Continue installing external packages by running"
echo ""
buildcmd="$cmake --build \"$builddir\" -j$ncpus"
echo $buildcmd
echo ""
echo "  or"
echo ""
echo "cd \"$builddir\""
echo "make -j$ncpus"
echo ""
