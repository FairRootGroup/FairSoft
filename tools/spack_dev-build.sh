#!/bin/bash

if [[ -z "${SPACK_ENV}" ]]; then
    echo "Activate spack environment before calling the script."
    return
fi

if [[ "$#" -ne 1 && "$#" -ne 3 ]]; then
    echo "Invalid number of parameter. Expects 1 or 3 parameters."
    echo "  1 parameter  : print the specs in dev-build format:"
    echo "    usage      : . ./spack_dev-build.sh package-name"
    echo "    example    : . ./spack_dev-build.sh fairroot"
    echo "  3 parameters : dev-build package in the given folder:"
    echo "    usage      : . ./spack_dev-build.sh package-name /path/to/package/source version"
    echo "    example    : . ./spack_dev-build.sh fairroot     \$HOME/spack/FairRootDev develop+sim+examples"
    return
fi

deps=$(spack python $SPACK_ROOT/../tools/find_specs.py $1);

if [[ "$#" -eq 1 ]]; then
    echo $deps;
    return
fi

coml="spack dev-build -j 4 -d $2 $1@$3 $deps";

echo $coml;

$coml
