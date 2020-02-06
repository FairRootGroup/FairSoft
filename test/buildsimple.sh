#! /bin/bash

. test/buildsetup.sh

spack -C ./config install "$@"
