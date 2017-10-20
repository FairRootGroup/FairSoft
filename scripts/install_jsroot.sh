#!/bin/bash
# Script install jsroot
echo "Downloading JSROOT"
if [ ! -d  $SIMPATH/tools/jsroot ];
then
  cd $SIMPATH/tools
  git clone $JSROOT_LOCATION
  cd $SIMPATH/tools/jsroot
  git checkout $JSROOTVERSION

fi
echo "Install prefix $SIMPATH_INSTALL"
if [ ! -d $SIMPATH_INSTALL/share/jsroot ];
	then
	cp -r $SIMPATH/tools/jsroot $SIMPATH_INSTALL/share/jsroot
fi
cd $SIMPATH
echo "*** JSROOT installed successfully ***"
return 1
