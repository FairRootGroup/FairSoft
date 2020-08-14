#! /bin/bash

if [ $# != 2 ]
then
	echo "*** Please call like: $0 LABEL JOBSH"
	exit 1
fi

label="$1"
jobsh="$2"

[ -e "build/${label}-last-exit-code" ] && rm "build/${label}-last-exit-code"

echo "*** Working directory ....: $PWD"
echo "*** Submitting job at ....: $(date -R)"
(
	set -x
	srun -p main -c 64 -n 1 -t 400 --job-name="${label}" bash "${jobsh}"
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
