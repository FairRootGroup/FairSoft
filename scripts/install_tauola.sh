#!/bin/bash

# This script installs tauloa 
# instructions copied from http://evtgen.warwick.ac.uk/static/srcrep/setupEvtGen.sh
install_prefix=$SIMPATH_INSTALL
osArch=`uname`
INSTALL_BASE=$SIMPATH/generators

if [ ! -d  $SIMPATH/generators/TAUOLA ];
 then
 cd $SIMPATH/generators
 download_file $TAUOLA_LOCATION/TAUOLA.$TAUOLA_VERSION/TAUOLA.$TAUOLA_VERSION.tar.gz
 tar -xzf TAUOLA.$TAUOLA_VERSION.tar.gz
# Patch TAUOLA on Darwin (Mac)
 if [ "$osArch" == "Darwin" ]
 then
  patch -p0 < $INSTALL_BASE/TAUOLA.$TAUOLA_VERSION/platform/tauola_Darwin.patch
 fi

 echo Installing TAUOLA
 cd TAUOLA/
 ./configure --with-hepmc=$SIMPATH_INSTALL --prefix=$SIMPATH_INSTALL
 make
 make install
fi

cd $SIMPATH

return 1
