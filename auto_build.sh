#!/bin/bash 

FORCE=false
#export SHIPSOFT=/opt/xocean
#export SIMPATH=$SHIPSOFT/FairSoftInst
#export FAIRROOTPATH=$SHIPSOFT/FairRootInst
#export FAIRSHIP=$SHIPSOFT/FairShip
#export FAIRSHIPRUN=$SHIPSOFT/FairShipRun

function halt() {
  echo $1
  exit 1
}

[ "$1" == "true" ] && FORCE=true
[ -z "$SIMPATH" ] && echo "SIMPATH is not defined" && exit 1
[ -d $SIMPATH && ! $FORCE ] && echo "$SIMPATH already exists" && exit 1
[ ! -d $SIMPATH ] && mkdir -p $SIMPATH
[ -f config.cache ] && rm config.cache

cat > answers.txt << EOT
1
3
1
2
1
$SIMPATH
2
EOT

./configure.sh < answers.txt || halt "Error running configure.sh"
./make_clean.sh all || halt "Error running make_clean.sh"
rm -rf basics/*zip basics/build tools/root
rm answers.txt
