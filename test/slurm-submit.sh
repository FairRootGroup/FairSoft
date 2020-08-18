#! /bin/bash

if [ $# != 2 ]
then
	echo "*** Please call like: $0 LABEL JOBSH"
	exit 1
fi

label="$1"
jobsh="$2"

[ -e "build/${label}-last-exit-code" ] && rm "build/${label}-last-exit-code"

if [ -z "$ALFACI_SLURM_CPUS" ]
then
	ALFACI_SLURM_CPUS=32
fi

echo "*** Working directory ....: $PWD"
echo "*** Requesting CPUs ......: $ALFACI_SLURM_CPUS"
echo "*** Submitting job at ....: $(date -R)"
(
	set -x
	srun -p main -c $ALFACI_SLURM_CPUS -n 1 -t 400 --job-name="${label}" bash "${jobsh}"
)
retval=$?
if [ "$retval" != 0 ]
then
	echo "*** Exit Code ............: $retval"
	exit $retval
fi

if [ "!" -r "build/${label}-last-exit-code" ]
then
	echo "*** Error reason .........: build/${label}-last-exit-code missing"
	exit 1
fi

retval="$(cat "build/${label}-last-exit-code")"
echo "*** Exit Code content ....: $retval"
exit "$retval"
