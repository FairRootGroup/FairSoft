#!/bin/bash 

export SHIPSOFT=/opt/_temp/ShipSoft
export SIMPATH=$SHIPSOFT/FairSoftInst
export FAIRROOTPATH=$SHIPSOFT/FairRootInst
export FAIRSHIP=$SHIPSOFT/FairShip
export FAIRSHIPRUN=$SHIPSOFT/FairShipRun

[ ! -d $SHIPSOFT ] && mkdir $SHIPSOFT
[ ! -d $SHIPSOFT/FairSoftInst ] && mkdir $SHIPSOFT/FairSoftInst
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
