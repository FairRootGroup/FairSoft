#! /bin/bash

if [ $# != 2 ]
then
	echo "*** Please call like: $0 CONTAINER CTESTCMD"
	exit 1
fi

container="$1"
ctestcmd="$2"

if [ -z "$FS_INSTALLTREE_BASE" ]
then
	FS_INSTALLTREE_BASE=/srv/alfaci/FairSoft/install-tree
fi
image="${SINGULARITY_CONTAINER_ROOT}/${container}"
bindmounts="/etc/environment,/cvmfs,$PWD"

if [ -d "$FS_INSTALLTREE_BASE" ]
then
	mkdir -p "$FS_INSTALLTREE_BASE/running"
	installtree="$(mktemp -d "$FS_INSTALLTREE_BASE/running/${LABEL}.${JOB_BASE_NAME}.XXX")"
	echo "*** New install tree .....: ${installtree}"
	bindmounts="${bindmounts},${installtree}:/opt/spack/install-tree"
	ctestcmd="${ctestcmd} -DFS_TEST_INSTALLTREE:PATH=/opt/spack/install-tree"
fi

set -x
exec singularity run -B"$bindmounts" "$image" ${ctestcmd}
