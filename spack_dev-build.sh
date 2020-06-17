#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Invalid number of parameter. Expects 3 parameters."
    echo "Usage  : . ./spack_dev-build.sh /path/to/package/source package-name package-options"
    echo "Example: . ./spack_dev-build.sh \$HOME/spack/FairRootDev fairroot     mybuild+sim+examples"
    return
fi

deps=$(spack find | sed -n '/Root/,/installed/p' | grep -v "Root specs" | grep -v ^$2@ | grep -v "installed packages" | sed 's/ //' | sed -e /^$/d | awk '{printf " ^%s",$0} END {print ""}');

coml="spack -C ./config dev-build -j 4 -d $1 $2@$3 $deps";

echo $coml;

$coml
