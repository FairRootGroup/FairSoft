#!/bin/bash 
#
# AlFa package installation script
# m.al-turany@gsi.de, Sept. 2014

install_alfasoft=yes
##################### FairSoft#############################################
source configure.sh

##################### FairRoot#############################################
if [ "$check" = "1" ];
then
source scripts/install_fairroot.sh
fi
##################### DDS     #############################################
if [ "$check" = "1" ];
then
source scripts/install_DDS.sh
fi
##################### AliRoot #############################################
if [ "$check" = "1" ];
then
source scripts/install_aliroot.sh
fi

