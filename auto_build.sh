#!/bin/bash 

FORCE=false

function halt() {
  echo $1
  exit 1
}

[ "$1" == "true" ] && FORCE=true
[ -z "$SIMPATH" ] && halt "SIMPATH is not defined"
[[ -d $SIMPATH && ! $FORCE ]] && halt "$SIMPATH directory already exists"
[ ! -d $SIMPATH ] && mkdir -p $SIMPATH
[ -f config.cache ] && rm config.cache
CONF="auto_build.conf"

cat > $CONF << EOT
compiler=gcc
debug=no
optimize=yes
geant4_download_install_data_automatic=yes
geant4_install_data_from_dir=no
build_python=yes
install_sim=yes
SIMPATH_INSTALL=$SIMPATH
platform=linux
EOT

./configure.sh $CONF || halt "Error running configure.sh"
./make_clean.sh all || halt "Error running make_clean.sh"
cat .gitignore | xargs rm -rf
rm $CONF
