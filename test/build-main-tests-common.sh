#! /bin/bash
#  -- to be sourced

. test/buildsetup.sh

echo -n "*** spack version ........: "
spack --version

echo -n "*** Actual test start time: "
date +%H:%M:%S
