#! /bin/bash

if [ $# != 2 ]
then
	echo "*** Please call like: $0 CONTAINER CTESTCMD"
	exit 1
fi

container="$1"
ctestcmd="$2"

# Some default paths:
: ${FS_INSTALLTREE_BASE:="/srv/alfaci/FairSoft/install-tree"}
: ${CONTAINER_ROOT:="/cvmfs/fairsoft_dev.gsi.de/ci/for-fairsoft/2022-11-24_1730/container"}

image="${CONTAINER_ROOT}/${container}"
bindmounts="/etc/environment,/cvmfs,$PWD"

if [ -d "$FS_INSTALLTREE_BASE" ]
then
	echo "*** Install-Tree (base) ..: $FS_INSTALLTREE_BASE"
	mkdir -p "$FS_INSTALLTREE_BASE/running"
	installtree="$(mktemp -d "$FS_INSTALLTREE_BASE/running/${LABEL}.${JOB_BASE_NAME}.XXX")"
	echo "***  During run ..........: ${installtree}"
	bindmounts="${bindmounts},${installtree}:/opt/spack/install-tree"
	ctestcmd="${ctestcmd} -DFS_TEST_INSTALLTREE:PATH=/opt/spack/install-tree"

	installtreecache="$FS_INSTALLTREE_BASE/cache/${LABEL}/job-${JOB_BASE_NAME}"
	if [ -d "$installtreecache" ]
	then
		echo "***  Found cache - copying: ${installtreecache}"
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
	echo "***  After finished run ..: $installtreecache"
fi

(
	set -x
	apptainer exec --writable-tmpfs -B"$bindmounts" "$image" bash -l -c "${ctestcmd}"
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
	echo "*** Caching install tree .: $installtreecache"
	mv "$installtree" "$installtreecache"
fi

exit $retval
