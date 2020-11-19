#!/bin/bash

cleanup() {
  rm -rf "$1"
}

if [ -z "$1" ]
then
  echo "Usage: bootstrap-cmake.sh INSTALLDIR"
  exit 1
else
  installdir=$(realpath $1)
fi

set -e
builddir=$(mktemp -d)
trap "cleanup ${builddir}" EXIT

pushd "${builddir}" > /dev/null

cmakebaseurl="https://github.com/Kitware/CMake/releases/download/v"
cmakeversion="3.18.3"
cmaketargz="cmake-${cmakeversion}-$(uname -s)-$(uname -m).tar.gz"
cmakechecksums="cmake-${cmakeversion}-SHA-256.txt"

cmake="${cmakebaseurl}${cmakeversion}/$cmaketargz"
echo "Downloading ${cmake}"
curl -L -O -# "${cmake}"

curl -L -O -s "${cmakebaseurl}${cmakeversion}/$cmakechecksums"
grep "$(uname -s).*$(uname -m).*\.tar\.gz" $cmakechecksums > checksum.txt
sha256sum -c checksum.txt

echo "Installing to ${installdir}"
mkdir -p "${installdir}"
tar xf "$cmaketargz" -C "$installdir" --strip-components=1

echo "Use via"
echo "  export PATH=${installdir}/bin:\$PATH"

popd > /dev/null
