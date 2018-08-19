#!/bin/bash

export CMAKE_LOCATION="http://www.cmake.org/files/v3.11/"
export CMAKEVERSION_REQUIRED=cmake-3.11.1
export CMAKEVERSION=cmake-3.11.1

export GTEST_LOCATION="https://github.com/google/googletest/archive"
export GTESTVERSION=release-1.7.0

export GSL_LOCATION="http://ftpmirror.gnu.org/gsl/"
export GSLVERSION=gsl-1.16

export ICU_LOCATION="http://download.icu-project.org/files/icu4c/53.1/"
export ICUVERSION=icu4c-53_1

export BOOST_LOCATION="http://sourceforge.net/projects/boost/files/boost/1.67.0/"
export BOOSTVERSION=boost_1_67_0

export PYTHIA6_LOCATION="https://root.cern.ch/download/"
export PYTHIA6VERSION=pythia6

export HEPMC_LOCATION="http://lcgapp.cern.ch/project/simu/HepMC/download/"
export HEPMCVERSION=2.06.09

export PYTHIA8_LOCATION="http://home.thep.lu.se/~torbjorn/pythia8/"
export PYTHIA8VERSION=pythia8212

export XERCESC_LOCATION="https://archive.apache.org/dist/xerces/c/3/sources/"
export XERCESCVERSION=3.1.2

export MESA_LOCATION="ftp://ftp.freedesktop.org/pub/mesa/older-versions/7.x/7.10.3/"
export MESAVERSION=MesaLib-7.10.3

export GEANT4_LOCATION="http://geant4.cern.ch/support/source/"
export GEANT4VERSION=geant4.10.04.p01
export GEANT4VERSIONp=Geant4-10.4.1

#export ROOT_LOCATION="http://root.cern.ch/git/root.git"
export ROOT_LOCATION="https://github.com/root-project/root"
#if [ "$build_root6" = "yes" ]; then
  # Root v6.10.00 (commit b630f34)
export ROOTVERSION=v6-12-06
  #export ROOTHASHVALUE=b630f342fdab71b7297d7bdb73ecfbefd71c884a
#else
  # Root v5.34.36
  # export ROOTVERSION=v5-34-36
#fi

export XROOTDVERSION=4.8.3

export PLUTO_LOCATION="http://web-docs.gsi.de/%7Ehadeshyp/pluto/v5.37/"
export PLUTOVERSION=pluto_v5.37

export GEANT3_LOCATION="https://github.com/FairRootGroup/geant3.git"
export GEANT3BRANCH=v2-5-gcc8

export VGM_LOCATION="https://github.com/vmc-project/vgm"
export VGMVERSION=v4-4
export VGMDIR=VGM-4.4.0

export GEANT4VMC_LOCATION="https://github.com/vmc-project/geant4_vmc.git"
export GEANT4VMCBRANCH=v3-6

export MILLEPEDE_LOCATION="http://svnsrv.desy.de/public/MillepedeII/tags/"
export MILLEPEDE_VERSION=V04-03-04

export SODIUM_LOCATION="https://github.com/jedisct1/libsodium"
export SODIUMBRANCH=1.0.3

# export ZEROMQ_LOCATION="https://github.com/zeromq/libzmq"
# If we bump higher than v4.2.5, we can use the upstream source again
export ZEROMQ_LOCATION="https://github.com/FairRootGroup/libzmq"
export ZEROMQ_VERSION=v4.2.5-fairroot

export PROTOBUF_LOCATION="https://github.com/google/protobuf/releases/download/v3.4.0"
export PROTOBUF_VERSION=3.4.0

export FLATBUFFERS_LOCATION="https://github.com/FairRootGroup/flatbuffers.git"
export FLATBUFFERS_BRANCH=v1.9.0-fairroot

export MSGPACK_LOCATION="https://github.com/FairRootGroup/msgpack-c.git"
export MSGPACK_BRANCH=cpp-2.1.5-fairroot

export NANOMSG_LOCATION="https://github.com/nanomsg/nanomsg/archive/"
#export NANOMSG_LOCATION="http://download.nanomsg.org/"
export NANOMSG_VERSION=1.0.0


export G4TENDL_VERSION=G4TENDL1.3.2
export G4TENDL_TAR=G4TENDL1.3.2.tar.gz

export G4ABLA_VERSION=G4ABLA3.1
export G4ABLA_TAR=G4ABLA3.1.tar.gz

export G4EMLOW_VERSION=G4EMLOW7.3
export G4EMLOW_TAR=G4EMLOW.7.3.tar.gz

export G4ENSDFSTATE_VERSION=G4ENSDFSTATE2.2
export G4ENSDFSTATE_TAR=G4ENSDFSTATE2.2.tar.gz

export G4NDL_VERSION=G4NDL4.5
export G4NDL_TAR=G4NDL.4.5.tar.gz

export G4NEUTRONXS_VERSION=G4NEUTRONXS1.4
export G4NEUTRONXS_TAR=G4NEUTRONXS.1.4.tar.gz

export G4PII_VERSION=G4PII1.3
export G4PII_TAR=G4PII.1.3.tar.gz

export G4SAIDDATA_VERSION=G4SAIDDATA1.1
export G4SAIDDATA_TAR=G4SAIDDATA.1.1.tar.gz

export PhotonEvaporation_VERSION=PhotonEvaporation5.2
export PhotonEvaporation_TAR=G4PhotonEvaporation.5.2.tar.gz

export RadioactiveDecay_VERSION=RadioactiveDecay5.2
export RadioactiveDecay_TAR=G4RadioactiveDecay5.2.tar.gz

export RealSurface_VERSION=RealSurface2.1
export RealSurface_TAR=RealSurface.2.1.tar.gz

export FAIRROOT_LOCATION="https://github.com/FairRootGroup/FairRoot.git"
export FAIRROOTVERSION=dev

export DDS_LOCATION="https://github.com/FairRootGroup/DDS.git"
export DDSVERSION=2.1-1-g181b66a

export ALIROOT_LOCATION="http://git.cern.ch/pub/AliRoot"
export ALIROOTVERSION=master

export FAIRLOGGER_LOCATION="https://github.com/FairRootGroup/FairLogger"
export FAIRLOGGER_VERSION=v1.2.0

export FAIRMQ_LOCATION="https://github.com/FairRootGroup/FairMQ"
export FAIRMQ_VERSION=v1.2.3
