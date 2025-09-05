#!/bin/bash

cleanup() {
  rm -rf "$1"
}

if [ -z "$1" ]
then
  echo "Usage: bootstrap-cmake.sh INSTALLDIR"
  exit 1
else
  installdir=$(realpath "$1")
  if [[ $? -ne 0 ]]; then
    echo ""
    echo "Install directory $installdir must exist on macOS."
    echo "Please create the directory."
    exit 1
  fi
fi

set -e
builddir=$(mktemp -d)
trap "cleanup ${builddir}" EXIT

pushd "${builddir}" > /dev/null

cmakebaseurl="https://github.com/Kitware/CMake/releases/download/v"
cmakeversion="4.2.3"
unames=$(uname -s | tr '[:upper:]' '[:lower:]')
unamem=$(uname -m | tr '[:upper:]' '[:lower:]')
if [[ "$unames" == "darwin" ]]; then
  cmaketargz="cmake-${cmakeversion}-macos-universal.tar.gz"
  grepstring="macos-universal.*\.tar\.gz"
else
  cmaketargz="cmake-${cmakeversion}-${unames}-${unamem}.tar.gz"
  grepstring="${unames}.*${unamem}.*\.tar\.gz"
fi

cmakechecksums="cmake-${cmakeversion}-SHA-256.txt"

cmake="${cmakebaseurl}${cmakeversion}/$cmaketargz"
echo "Downloading ${cmake}"
curl -L -O -# "${cmake}"

curl -L -O -s "${cmakebaseurl}${cmakeversion}/$cmakechecksums"
grep "$grepstring" $cmakechecksums > checksum.txt
sha256sum -c checksum.txt

echo "Installing to ${installdir}"
if [[ "$unames" == "darwin" ]]; then
  tar xf "$cmaketargz" -C "$PWD" --strip-components=1
  cp -r CMake.app/Contents/bin "${installdir}"
  cp -r CMake.app/Contents/doc "${installdir}"
  cp -r CMake.app/Contents/man "${installdir}"
  cp -r CMake.app/Contents/share "${installdir}"
else
  mkdir -p "${installdir}"
  tar xf "$cmaketargz" -C "$installdir" --strip-components=1
fi

echo "Use via"
echo "  export PATH=${installdir}/bin:\$PATH"

popd > /dev/null
