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
if [ -z "$ALFACI_SLURM_TIMEOUT" ]
then
	ALFACI_SLURM_TIMEOUT=480
fi
if [ -z "$ALFACI_SLURM_QUEUE" ]
then
	ALFACI_SLURM_QUEUE=main
fi

echo "*** Slurm request options :"
echo "***   Working directory ..: $PWD"
echo "***   Queue ..............: $ALFACI_SLURM_QUEUE"
echo "***   CPUs ...............: $ALFACI_SLURM_CPUS"
echo "***   Wall Time ..........: $ALFACI_SLURM_TIMEOUT min"
echo "*** Submitting job at ....: $(date -R)"
(
	set -x
	srun -p $ALFACI_SLURM_QUEUE -c $ALFACI_SLURM_CPUS -n 1 \
		-t $ALFACI_SLURM_TIMEOUT --job-name="${label}" \
		bash "${jobsh}"
)
retval=$?
if [ "$retval" != 0 ]
then
	echo "*** srun Exit Code .......: $retval"
	# exit $retval
	echo "***"
	echo "***  /!\  Ignoring it, because it used to be unreliable."
	echo "***"
fi

if [ "!" -r "build/${label}-last-exit-code" ]
then
	echo "*** ERROR reason .........: build/${label}-last-exit-code missing"
	exit 1
fi

retval="$(cat "build/${label}-last-exit-code")"
echo "*** Exit Code content ....: $retval"
exit "$retval"
