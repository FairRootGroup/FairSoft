#!/bin/bash

export CMAKE_LOCATION="http://www.cmake.org/files/v3.11/"
export CMAKEVERSION_REQUIRED=cmake-3.11.1
export CMAKEVERSION=cmake-3.11.1

export GTEST_LOCATION="https://github.com/google/googletest/archive"
export GTESTVERSION=release-1.8.1

export GSL_LOCATION="http://ftpmirror.gnu.org/gsl/"
export GSLVERSION=gsl-2.5

export ICU_LOCATION="http://download.icu-project.org/files/icu4c/63.1/"
export ICUVERSION=icu4c-63_1

export BOOST_LOCATION="http://sourceforge.net/projects/boost/files/boost/1.69.0/"
export BOOSTVERSION=boost_1_69_0

export PYTHIA6_LOCATION="https://root.cern.ch/download/"
export PYTHIA6VERSION=pythia6

export HEPMC_LOCATION="http://lcgapp.cern.ch/project/simu/HepMC/download/"
export HEPMCVERSION=2.06.09

export PYTHIA8_LOCATION="http://home.thep.lu.se/~torbjorn/pythia8/"
export PYTHIA8VERSION=pythia8240

export XERCESC_LOCATION="https://archive.apache.org/dist/xerces/c/3/sources/"
export XERCESCVERSION=3.1.2

export MESA_LOCATION="ftp://ftp.freedesktop.org/pub/mesa/older-versions/7.x/7.10.3/"
export MESAVERSION=MesaLib-7.10.3

export GEANT4_LOCATION="https://github.com/Geant4/geant4.git/"
export GEANT4VERSION=geant4-10.5-release
export GEANT4VERSIONp=Geant4-10.5.0

#export ROOT_LOCATION="http://root.cern.ch/git/root.git"
export ROOT_LOCATION="https://github.com/root-project/root"
#if [ "$build_root6" = "yes" ]; then
  # Root v6.10.00 (commit b630f34)
export ROOTVERSION=v6-16-00
  #export ROOTHASHVALUE=b630f342fdab71b7297d7bdb73ecfbefd71c884a
#else
  # Root v5.34.36
  # export ROOTVERSION=v5-34-36
#fi

export XROOTDVERSION=4.8.3

export PLUTO_LOCATION="http://web-docs.gsi.de/%7Ehadeshyp/pluto/v5.37/"
export PLUTOVERSION=pluto_v5.37

export GEANT3_LOCATION="https://github.com/FairRootGroup/geant3.git"
export GEANT3BRANCH=v2-6

export VGM_LOCATION="https://github.com/vmc-project/vgm"
export VGMVERSION=v4-5
export VGMDIR=VGM-4.5.0

export GEANT4VMC_LOCATION="https://github.com/vmc-project/geant4_vmc.git"
export GEANT4VMCBRANCH=v4-0

export MILLEPEDE_LOCATION="http://svnsrv.desy.de/public/MillepedeII/tags/"
export MILLEPEDE_VERSION=V04-03-10

export SODIUM_LOCATION="https://github.com/jedisct1/libsodium"
export SODIUMBRANCH=1.0.17

# export ZEROMQ_LOCATION="https://github.com/zeromq/libzmq"
# If we bump higher than v4.2.5, we can use the upstream source again
export ZEROMQ_LOCATION="https://github.com/FairRootGroup/libzmq"
export ZEROMQ_VERSION=v4.3.1

export PROTOBUF_LOCATION="https://github.com/google/protobuf/releases/download/v3.6.1"
export PROTOBUF_VERSION=3.6.1

export FLATBUFFERS_LOCATION="https://github.com/google/flatbuffers.git"
export FLATBUFFERS_BRANCH=v1.10.0

export MSGPACK_LOCATION="https://github.com/msgpack/msgpack-c"
export MSGPACK_VERSION=cpp-3.1.1

export NANOMSG_LOCATION="https://github.com/nanomsg/nanomsg"
export NANOMSG_VERSION=1.1.5


############## Gent4 Data files

export G4NDL_VERSION=G4NDL4.5
export G4NDL_TAR=G4NDL.4.5.tar.gz

export G4EMLOW_VERSION=G4EMLOW7.7
export G4EMLOW_TAR=G4EMLOW.7.7.tar.gz

export PhotonEvaporation_VERSION=PhotonEvaporation5.3
export PhotonEvaporation_TAR=G4PhotonEvaporation.5.3.tar.gz

export RadioactiveDecay_VERSION=RadioactiveDecay5.3
export RadioactiveDecay_TAR=G4RadioactiveDecay5.3.tar.gz

export G4SAIDDATA_VERSION=G4SAIDDATA2.0
export G4SAIDDATA_TAR=G4SAIDDATA.2.0.tar.gz

export G4PARTICLEXS_VERSION=G4PARTICLEXS1.1
export G4PARTICLEXS_TAR=G4PARTICLEXS1.1.tar.gz

export G4ABLA_VERSION=G4ABLA3.1
export G4ABLA_TAR=G4ABLA3.1.tar.gz

export G4INCL_VERSION=G4INCL1.0
export G4INCL_TAR=G4INCL1.0.tar.gz

export G4PII_VERSION=G4PII1.3
export G4PII_TAR=G4PII.1.3.tar.gz

export G4ENSDFSTATE_VERSION=G4ENSDFSTATE2.2
export G4ENSDFSTATE_TAR=G4ENSDFSTATE2.2.tar.gz

export G4RealSurface_VERSION=RealSurface2.1.1
export G4RealSurface_TAR=G4RealSurface.2.1.1.tar.gz

export G4TENDL_VERSION=G4TENDL1.3.2
export G4TENDL_TAR=G4TENDL1.3.2.tar.gz

############################


export FAIRROOT_LOCATION="https://github.com/FairRootGroup/FairRoot.git"
export FAIRROOTVERSION=dev

export DDS_LOCATION="https://github.com/FairRootGroup/DDS.git"
export DDSVERSION=2.2

export ALIROOT_LOCATION="http://git.cern.ch/pub/AliRoot"
export ALIROOTVERSION=master

export FAIRLOGGER_LOCATION="https://github.com/FairRootGroup/FairLogger"
export FAIRLOGGER_VERSION=v1.4.0

export FAIRMQ_LOCATION="https://github.com/FairRootGroup/FairMQ"
export FAIRMQ_VERSION=v1.3.7

export OFI_LOCATION="https://github.com/ofiwg/libfabric"
export OFI_TESTS_LOCATION="https://github.com/ofiwg/fabtests"
export OFI_VERSION=v1.6.2

export ASIOFI_LOCATION="https://github.com/FairRootGroup/asiofi"
export ASIOFI_VERSION=master
