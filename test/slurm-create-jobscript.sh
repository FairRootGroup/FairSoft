#! /bin/bash

if [ $# != 4 ]
then
	echo "*** Please call like: $0 LABEL CONTAINER CTESTCMD JOBSH"
	exit 1
fi

label="$1"
container="$2"
ctestcmd="$3"
jobsh="$4"

echo "*** Creating job script ..: ${jobsh}"

(
	echo '#! /bin/bash'
	echo "export LABEL=${label}"
	echo 'echo "*** Job started at .......: $(date -R)"'
	echo 'echo "*** Job ID ...............: $SLURM_JOB_ID"'
	echo 'export SPACK_BUILD_JOBS=$SLURM_CPUS_PER_TASK'
	echo "source <(sed -e '/^#/d' -e '/^export/!s/^.*=/export &/' /etc/environment)"
	printf './test/test-start-container.sh %q %q\n' "${container}" "${ctestcmd}"
	echo 'retval=$?'
	echo 'mkdir -p build'
	echo 'echo $retval >"build/${LABEL}-last-exit-code"'
	echo 'exit $retval'
) > "$jobsh"

echo "*** Content:"
sed -e 's/^/    /' "$jobsh"
