#! /bin/bash

. test/buildsetup.sh

spack -C ./config spec -I "$@"
retval=$?

if [ "$retval" != "0" ]
then
	exit $retval
fi

spack -C ./config install "$@"
