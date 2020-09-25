#! /bin/bash

if [ $# != 2 ]
then
	echo "*** Please call like: $0 LABEL JOBSH"
	exit 1
fi

label="$1"
jobsh="$2"

slurmlabel="$label"
if [ -n "$JOB_NAME" ]
then
	jobname="$(echo $JOB_NAME | sed -e 's/^.*\/\([^\/]*\/[^\/]*\)/\1/')"
	slurmlabel="$jobname $slurmlabel"
fi
if [ -n "$BUILD_DISPLAY_NAME" ]
then
	slurmlabel="$slurmlabel $BUILD_DISPLAY_NAME"
fi


[ -e "build/${label}-last-exit-code" ] && rm "build/${label}-last-exit-code"

if [ -z "$ALFACI_SLURM_CPUS" ]
then
	ALFACI_SLURM_CPUS=32
fi
if [ -z "$ALFACI_SLURM_EXTRA_OPTS" ]
then
	ALFACI_SLURM_EXTRA_OPTS="--hint=compute_bound"
fi
if [ -z "$ALFACI_SLURM_TIMEOUT" ]
then
	ALFACI_SLURM_TIMEOUT=480
fi
if [ -z "$ALFACI_SLURM_QUEUE" ]
then
	ALFACI_SLURM_QUEUE=main
fi
if [ -n "$BRANCH_NAME" ] && [ -z "$CHANGE_ID" ]
then
	# jenkins: Building branch, not PR
	ALFACI_SLURM_EXTRA_OPTS="${ALFACI_SLURM_EXTRA_OPTS} --nice=1000"
fi

echo "*** Slurm request options :"
echo "***   Working directory ..: $PWD"
echo "***   Queue ..............: $ALFACI_SLURM_QUEUE"
echo "***   CPUs ...............: $ALFACI_SLURM_CPUS"
echo "***   Wall Time ..........: $ALFACI_SLURM_TIMEOUT min"
echo "***   Job Name ...........: ${slurmlabel}"
echo "***   Extra Options ......: ${ALFACI_SLURM_EXTRA_OPTS}"
echo "*** Submitting job at ....: $(date -R)"
(
	set -x
	srun -p $ALFACI_SLURM_QUEUE -c $ALFACI_SLURM_CPUS -n 1 \
		-t $ALFACI_SLURM_TIMEOUT \
		--job-name="${slurmlabel}" \
		${ALFACI_SLURM_EXTRA_OPTS} \
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
