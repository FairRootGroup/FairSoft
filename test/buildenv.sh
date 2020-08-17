#! /bin/bash

. test/buildsetup.sh

envname="$(echo "${1}" | \
	sed \
		-e 's/\<env[/]//' \
		-e 's/[.]yaml$//' \
		-e 's/spack$//' \
		-e 's/[^a-z]*//g')"
echo "*** Name for environment .: $envname"

echo "*** Environment file .....: $1"
echo "*** Contents:"
sed -e 's/^/    /' "$1"

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
spack env deactivate
spack env rm -y $envname
exit $ret
