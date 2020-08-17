#!/bin/bash

fairsoft_basedir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fairsoft_spackdir=vae/spack
fairsoft_configdir=../../../config

if command -v git >/dev/null 2>&1
then
	(cd "$fairsoft_basedir" && git submodule update --init)
fi

. "${fairsoft_basedir}/${fairsoft_spackdir}/share/spack/setup-env.sh"
spack compiler find

(
cd "${fairsoft_basedir}/${fairsoft_spackdir}/etc/spack/${fairsoft_configdir}"
for config_entry in *
do
	case "$config_entry" in
		*~)
			continue
			;;
		.*)
			continue
			;;
	esac
	if [ "!" -e "${fairsoft_basedir}/${fairsoft_spackdir}/etc/spack/${config_entry}" ]
	then
		ln -s "${fairsoft_configdir}/${config_entry}" \
			"${fairsoft_basedir}/${fairsoft_spackdir}/etc/spack/${config_entry}"
	else
		fairsoft_readlink="$(readlink "${fairsoft_basedir}/${fairsoft_spackdir}/etc/spack/${config_entry}")"
		if [ "$fairsoft_readlink" != "${fairsoft_configdir}/${config_entry}" ]
		then
			echo "!!! WARNING"
			echo "!!! ${fairsoft_basedir}/${fairsoft_spackdir}/etc/spack/${config_entry}"
			echo "!!! does not point to the right target"
			echo "!!! It should be a symlink to:"
			echo "!!!     ${fairsoft_configdir}/${config_entry}"
			echo "!!! Currently either not a symlink or points to:"
			echo "!!!     $fairsoft_readlink"
		fi
	fi
done
)

fairsoft_repo() {
	if [ "$(spack repo list | sed -n -e "/^$1 / { s/^[^ ]* *//; p; }")" != "${fairsoft_basedir}/repos/$2" ]
	then
		spack repo add --scope site "${fairsoft_basedir}/repos/$2"
	fi
}

fairsoft_repo "vae_backports" "vae-backports"
fairsoft_repo "fairsoft_backports" "fairsoft-backports"
fairsoft_repo "fairsoft" "fairsoft"

spack clean -ms

unset -f fairsoft_repo
unset fairsoft_basedir
unset fairsoft_spackdir
unset fairsoft_configdir
