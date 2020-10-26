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
    echo "           CentOS: yum install $cmd"
    echo "         OpenSuse: zypper install $cmd"
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

show_dialog --title "PACKAGE_SET" \
  --radiolist "Which set of external packages do you want to install?" 12 90 4 \
    full "All dependencies" on \
    fairmq "FairMQ and dependencies only" off \
    fairmqdev "FairMQ development dependencies only" off

case $? in
  $DIALOG_OK) packages=$result ;;
  *) dialog_default_handlers $? ;;
esac

### package options
GEANT4MT=OFF

if [ $packages == "full" ]
then
  show_dialog --title "Package options" \
    --checklist "" 8 72 1 \
    GEANT4MT "Enable multi-threading in Geant4" off

  case $? in
    $DIALOG_OK)
      res=($result)
      for k in "${res[@]}"; do declare "${k}=ON"; done
      ;;
    *) dialog_default_handlers $? ;;
  esac
fi

### compile options
build_type=RelWithDebInfo

show_dialog --title "CMAKE_BUILD_TYPE" \
  --radiolist "" 10 62 3 \
    RelWithDebInfo "Optimized and debug information" on \
    Debug "Debug information" off \
    Release "Optimized" off

echo $result
case $? in
  $DIALOG_OK) build_type=$result ;;
  *) dialog_default_handlers $? ;;
esac

### directories
version=$(git -C $basedir describe --tags)
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
    "CMAKE_BINARY_DIR"      2 2 "$builddir"   2 24 80 300 \
    "CMAKE_INSTALL_PREFIX"  3 2 "$installdir" 3 24 80 300 \
    "NCPUS"                 4 2 "$ncpus"      4 24 3 3

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
    "PACKAGE_SET"           2 2 "$packages"   2 24 0 0 \
    "GEANT4MT"              3 2 "$GEANT4MT"   3 24 0 0 \
    "CMAKE_BUILD_TYPE"      4 2 "$build_type" 4 24 0 0 \
    "CMAKE_BINARY_DIR"      5 2 "$builddir"   5 24 0 0 \
    "CMAKE_INSTALL_PREFIX"  6 2 "$installdir" 6 24 0 0 \
    "NCPUS"                 7 2 "$ncpus"      7 24 0 0

case $? in
  $DIALOG_OK) ;;
  *) dialog_default_handlers $? ;;
esac

mkdir -p "$builddir"
mkdir -p "$installdir"

### bootstrap cmake if needed
too_old=1
required=3.16.1
if command -v cmake > /dev/null
then
  current=$(cmake --version | head -1 | cut -d' ' -f3)
  check="${required}\n${current}\n"
  printf $check | sort -V -C
  too_old=$?
fi

if [ $too_old -eq 1 ]
then
  cmake="${installdir}/bin/cmake"
  if [ ! -f "$cmake" ]
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
  fi
else
  cmake=cmake
fi

### configure
confcmd="$cmake -S $basedir -B $builddir \
-DBUILD_METHOD=legacy \
-DCMAKE_INSTALL_PREFIX=$installdir \
-DCMAKE_BUILD_TYPE=$build_type \
-DPACKAGE_SET=$packages \
-DNCPUS=$ncpus \
-DGEANT4MT=$GEANT4MT \
$@"

(
set -x
$confcmd
)

echo ""
echo ">>> Configured FairSoft with command"
echo ""
echo "    $confcmd"
echo ""
echo ">>> Continue building/installing by running"
echo ""
buildcmd="$cmake --build $builddir -j$ncpus"
echo $buildcmd
echo ""
