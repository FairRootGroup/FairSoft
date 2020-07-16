#! /bin/bash

. test/buildsetup.sh

envname="$(echo "${1}" | sed -e 's/^env[/]//' -e 's/[.]yaml$//' -e 's/[^a-z]*//g')"
echo "*** Name for environment .: $envname"

echo "*** Environment file .....: $1"
echo "*** Contents:"
sed -e 's/^/    /' "$1"

spack env create $envname "$1" || exit 1
spack env activate $envname
ret=$?
if [ "$ret" = 0 ]
then
	spack -C ./config install
	ret=$?
fi
spack env deactivate
spack env rm -y $envname
exit $ret
