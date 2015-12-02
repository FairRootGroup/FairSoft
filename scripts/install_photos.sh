#!/bin/bash

# This script installs photos 
# instructions copied from http://evtgen.warwick.ac.uk/static/srcrep/setupEvtGen.sh
osArch=`uname`
INSTALL_BASE=$SIMPATH/generators

if [ ! -d  $SIMPATH/generators/PHOTOS ];
 then
 cd $SIMPATH/generators
 # curl -O http://photospp.web.cern.ch/photospp/resources/PHOTOS.3.61/PHOTOS.3.61.tar.gz
 download_file $PHOTOS_LOCATION/PHOTOS.$PHOTOS_VERSION/PHOTOS.$PHOTOS_VERSION.tar.gz
 tar -xzf PHOTOS.$PHOTOS_VERSION.tar.gz
# Patch TAUOLA on Darwin (Mac)
 if [ "$osArch" == "Darwin" ]
 then
  patch -p0 < $INSTALL_BASE/$PHOTOS_VERSION/platform/photos_Darwin.patch
 fi

 echo Installing PHOTOS
 cd PHOTOS/
 ./configure --with-hepmc=$SIMPATH_INSTALL --prefix=$SIMPATH_INSTALL
 make
 make install
fi

cd $SIMPATH

return 1
