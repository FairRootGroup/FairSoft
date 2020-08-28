#! /bin/bash

. test/build-main-tests-common.sh

envname="$(echo "${1}" | \
	sed \
		-e 's/\<env[/]//' \
		-e 's/[.]yaml$//' \
		-e 's/spack$//' \
		-e 's/[^a-z0-9]*//g')"
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
if [ "$ret" = 0 -a -n "$2" ]
then
  uname="$(uname)"
  if [ "$uname" = Linux ]
  then
    postworkdir="$(mktemp -d -p $HOME XXXXXX)"
  elif [ "$uname" = Darwin ]
  then
    pushd $HOME
    postworkdir="$(realpath ./$(mktemp -d XXXXXX))"
    popd
  else
    echo "*** ERROR: Unsupported system: $uname"
    exit 1
  fi
  echo "*** Post script workdir ..: $postworkdir"
  echo "*** Post script ..........: $2"
  echo "*** Contents:"
  sed -e 's/^/    /' "$2"
  postscript="$(realpath $2)"
  pushd $postworkdir
	$postscript
	ret=$?
  popd
else
  echo "*** Skipping post script"
fi
spack env deactivate
spack env rm -y $envname
exit $ret
