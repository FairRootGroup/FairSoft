#! /bin/bash

. test/build-main-tests-common.sh

envname="$(echo "${1}" | \
	sed \
		-e 's/\<env[/]//' \
		-e 's/[.]yaml$//' \
		-e 's/spack$//' \
		-e 's/[^a-z0-9_]*//g' \
		-e 's/^/fs_test_/')"
echo "*** Name for environment .: $envname"

echo "*** Environment file .....: $1"
echo "*** Contents:"
sed -e 's/^/    /' "$1"

if [ -n "$2" ]
then
	uname="$(uname)"
	if [ "$uname" = Linux ]
	then
		postworkdir="$(mktemp -d -p $FS_TEST_WORKDIR env_post_workdir.XXX)"
	elif [ "$uname" = Darwin ]
	then
		pushd $FS_TEST_WORKDIR
		postworkdir="$(realpath ./$(mktemp -d env_post_workdir.XXX))"
		popd
	else
		echo "*** ERROR: Unsupported system: $uname"
		exit 1
	fi
	echo "*** Post script workdir ..: $postworkdir"
	echo "*** Post script ..........: $2"
	echo "*** Contents:"
	sed -e 's/^/    /' "$2"
fi


if spack env list | grep -q "^ *$envname *$"
then
	echo "*** Removing old left over environment from previous run"
	spack env rm -y $envname
fi

spack env create $envname "$1" || exit 1
spack env activate $envname
ret=$?
if [ "$ret" = 0 ]
then
	spack install
	ret=$?
fi
if [ "$ret" = 0 -a -n "$2" ]
then
	echo "***"
	echo "***       Starting post script"
	echo "***       ===================="
	echo "***"
	postscript="$(realpath $2)"
	pushd $postworkdir
	export ENVNAME=$envname
	$postscript
	ret=$?
	popd
else
	echo "*** Skipping post script"
fi
spack env deactivate
spack env rm -y $envname
exit $ret
