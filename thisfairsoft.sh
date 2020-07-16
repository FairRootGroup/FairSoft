#!/bin/bash

command -v git >/dev/null 2>&1 && git submodule update --init
. spack/share/spack/setup-env.sh
spack compiler find
