#!/bin/bash 

FORCE=false
export SHIPSOFT=/opt/xocean
export SIMPATH=$SHIPSOFT/FairSoftInst
export FAIRROOTPATH=$SHIPSOFT/FairRootInst
export FAIRSHIP=$SHIPSOFT/FairShip
export FAIRSHIPRUN=$SHIPSOFT/FairShipRun

[ "$1" == "true" ] && FORCE=true
[ -d $SHIPSOFT && ! $FORCE ] && echo "$SHIPSOFT already exists" && exit 1
[ ! -d $SHIPSOFT ] && mkdir -p $SHIPSOFT
[ ! -d $SHIPSOFT/FairSoftInst ] && mkdir -p $SHIPSOFT/FairSoftInst
[ -f config.cache ] && rm config.cache

cat > answers.txt << EOT
1
3
1
2
1
$SHIPSOFT/FairSoftInst
2
EOT

./configure.sh < answers.txt
./make_clean.sh all false
