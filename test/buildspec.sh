#! /bin/bash

. test/build-main-tests-common.sh

echo "*** Spec to be build .....:" "$@"

spack spec -I "$@"
retval=$?

if [ "$retval" != "0" ]
then
	exit $retval
fi

spack install "$@"
