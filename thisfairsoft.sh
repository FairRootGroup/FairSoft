#!/bin/bash

fairsoft_basedir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if command -v git >/dev/null 2>&1
then
	(cd "$fairsoft_basedir" && git submodule update --init)
fi

. "${fairsoft_basedir}/spack/share/spack/setup-env.sh"
spack compiler find

if [ "$(spack repo list | sed -n -e "/^fairsoft / { s/^[^ ]* *//; p; }")" != "$fairsoft_basedir" ]
then
	spack repo add --scope site "$fairsoft_basedir"
fi

unset fairsoft_basedir
