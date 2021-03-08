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

	installtreecache="$FS_INSTALLTREE_BASE/cache/${LABEL}/job-${JOB_BASE_NAME}"
	if [ -d "$installtreecache" ]
	then
		echo "*** Found cache - copying : ${installtreecache}"
		cp -a --reflink=auto "$installtreecache/." "$installtree/."
	else
		if [ -n "$CHANGE_TARGET" ]
		then
			it_from_merge_target="$FS_INSTALLTREE_BASE/cache/${LABEL}/job-${CHANGE_TARGET}"
			if [ -d "$it_from_merge_target" ]
			then
				echo "*** Copying branch cache .: ${it_from_merge_target}"
				cp -a --reflink=auto "${it_from_merge_target}/." "$installtree/."
			fi
		fi
	fi
fi

(
	set -x
	singularity exec -B"$bindmounts" "$image" bash -l -c "${ctestcmd}"
)
retval=$?

if [ -d "$FS_INSTALLTREE_BASE" ] && [ -d "$installtree" ]
then
	mkdir -v -p "$FS_INSTALLTREE_BASE/cache/${LABEL}"
	mkdir -v -p "$FS_INSTALLTREE_BASE/old/${LABEL}"
	rm -rf "$FS_INSTALLTREE_BASE/old/${LABEL}/job-${JOB_BASE_NAME}"
	if [ -d "$installtreecache" ]
	then
		mv -v "$installtreecache" \
		   "$FS_INSTALLTREE_BASE/old/${LABEL}/job-${JOB_BASE_NAME}"
	fi
	mv -v "$installtree" "$installtreecache"
fi

exit $retval
