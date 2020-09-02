#!/bin/bash

fairsoft_basedir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fairsoft_spackdir=vae/spack
fairsoft_configdir=../../../config

if [ "$1" = "--setup" ]
then
	fairsoft_do_setup=true
else
	fairsoft_do_setup=false
fi

if $fairsoft_do_setup && command -v git >/dev/null 2>&1
then
	(cd "$fairsoft_basedir" && git submodule update --init)
fi

. "${fairsoft_basedir}/${fairsoft_spackdir}/share/spack/setup-env.sh"

if $fairsoft_do_setup
then
	spack compiler find
fi

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
	fairsoft_symlink_from="${fairsoft_basedir}/${fairsoft_spackdir}/etc/spack/${config_entry}"
	if [ "!" -e "$fairsoft_symlink_from" ] && [ "!" -L "$fairsoft_symlink_from" ]
	then
		if $fairsoft_do_setup
		then
			ln -s "${fairsoft_configdir}/${config_entry}" \
				"$fairsoft_symlink_from"
		else
			echo '!!!' >&2
			echo '!!! ==========================  /!\  WARNING  ==========================' >&2
			echo "!!! $fairsoft_symlink_from" >&2
			echo "!!! should be a symlink into the FairSoft config directory" >&2
			echo "!!! Consider running the setup once:" >&2
			echo "!!!     -->  source ${BASH_SOURCE[0]} --setup" >&2
		fi
	else
		fairsoft_readlink="$(readlink "$fairsoft_symlink_from")"
		if [ "$fairsoft_readlink" != "${fairsoft_configdir}/${config_entry}" ]
		then
			echo '!!!' >&2
			echo '!!! ==========================  /!\  WARNING  ==========================' >&2
			echo "!!! $fairsoft_symlink_from" >&2
			echo "!!! does not point to the right target" >&2
			echo "!!! It should be a symlink to:" >&2
			echo "!!!     ${fairsoft_configdir}/${config_entry}" >&2
			echo "!!! Currently either not a symlink or points to:" >&2
			echo "!!!     $fairsoft_readlink" >&2
		fi
	fi
done
)

fairsoft_repo() {
	if [ "$(spack repo list | sed -n -e "/^$1 / { s/^[^ ]* *//; p; }")" != "${fairsoft_basedir}/repos/$2" ]
	then
		if $fairsoft_do_setup
		then
			spack repo add --scope site "${fairsoft_basedir}/repos/$2"
		else
			echo '!!!' >&2
			echo '!!! ==========================  /!\  WARNING  ==========================' >&2
			echo "!!! spack repo $1 ($2) missing" >&2
			echo "!!! Consider running the setup once:" >&2
			echo "!!!     -->  source ${BASH_SOURCE[0]} --setup" >&2
		fi
	fi
}

fairsoft_repo "vae_backports" "vae-backports"
fairsoft_repo "fairsoft_backports" "fairsoft-backports"
fairsoft_repo "fairsoft" "fairsoft"

if $fairsoft_do_setup
then
	spack clean -ms
fi

unset -f fairsoft_repo
unset fairsoft_basedir
unset fairsoft_spackdir
unset fairsoft_configdir
unset fairsoft_do_setup
