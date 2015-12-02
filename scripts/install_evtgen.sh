#!/bin/bash

# This script installs EvtGen with all external dependencies. The variable VERSION specifies
# the tag of EvtGen you want to use. The list of available tags can be found using either the 
# command "svn ls -v http://svn.cern.ch/guest/evtgen/tags" or by going to the url
# http://svn.cern.ch/guest/evtgen/tags in a web browser. Note that some earlier EvtGen versions
# will not be compatible with all external dependency versions given below, owing to C++
# interface differences; see the specific tagged version of the EvtGen/README file for guidance
osArch=`uname`
INSTALL_BASE=$SIMPATH/generators

# Version or tag number. No extraneous spaces on this line!
if [ ! -d  $SIMPATH/generators/EvtGen ];then
 cd $SIMPATH/generators
 mkdir -p EvtGen
 cd EvtGen

 echo Will setup EvtGen $EVTGEN_VERSION

 echo Downloading EvtGen from SVN
 svn export http://svn.cern.ch/guest/evtgen/tags/$EVTGEN_VERSION

 echo Building EvtGen $EVTGEN_VERSION
 cd $EVTGEN_VERSION
# -llhapdfdummy does not exist anymore for newer versions of Pythia8!
 mysed "-llhapdfdummy" " " configure
 ./configure --hepmcdir=$SIMPATH_INSTALL --photosdir=$SIMPATH_INSTALL --pythiadir=$SIMPATH_INSTALL --tauoladir=$SIMPATH_INSTALL
 make

 echo Setup done.
 echo To complete, add the following command to your .bashrc file or run it in your terminal before running any programs that use the EvtGen library:
 echo LD_LIBRARY_PATH=$INSTALL_BASE/external/HepMC/lib:$INSTALL_BASE/external/pythia8186/lib:$INSTALL_BASE/external/PHOTOS/lib:$INSTALL_BASE/external/TAUOLA/lib:$INSTALL_BASE/ $VERSION/lib:\$LD_LIBRARY_PATH 
 echo Also set the Pythia8 data path:
 echo PYTHIA8DATA=$SIMPATH_INSTALL/share/pythia8/xmldoc
fi

cd $SIMPATH

return 1
