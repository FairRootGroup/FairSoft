#!/bin/bash

fairsoft_basedir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if command -v git >/dev/null 2>&1
then
	(cd "$fairsoft_basedir" && git submodule update --init)
fi

. "${fairsoft_basedir}/vae/spack/share/spack/setup-env.sh"
spack compiler find

fairsoft_repo() {
	if [ "$(spack repo list | sed -n -e "/^$1 / { s/^[^ ]* *//; p; }")" != "${fairsoft_basedir}/repos/$2" ]
	then
		spack repo add --scope site "${fairsoft_basedir}/repos/$2"
	fi
}

fairsoft_repo "vae_backports" "vae-backports"
fairsoft_repo "fairsoft_backports" "fairsoft-backports"
fairsoft_repo "fairsoft" "fairsoft"

unset -f fairsoft_repo
unset fairsoft_basedir
