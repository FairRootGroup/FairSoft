#!/bin/bash 

FORCE=false

function halt() {
  echo $1
  exit 1
}

[ "$1" == "true" ] && FORCE=true
[ -z "$SIMPATH" ] && halt "SIMPATH is not defined"
[ -d $SIMPATH && ! $FORCE ] && halt "$SIMPATH directory already exists"
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
cat .gitignore | xargs rm -rf
rm answers.txt
