#! /bin/bash


zypper refresh && zypper update -y
zypper install --no-recommends -y \
      autoconf automake binutils bison bzip2 libbz2-devel cmake \
      ca-certificates coreutils curl libcurl-devel diffutils expat libexpat-devel \
      fftw-devel findutils flex gcc-c++ gcc-fortran gdbm-devel gettext-devel git gperf gsl-devel \
      gzip help2man hostname htop hwloc hwloc-devel joe m4 make libbsd-devel libtool libicu-devel \
      glu-devel grpc-devel libunistring-devel libuuid-devel libX11-devel libXau-devel \
      libXdmcp-devel libXext-devel libXfont-devel libXft-devel libxml2-devel \
      libXmu-devel libXpm-devel libXrender-devel liblz4-devel libzstd-devel lsb-release Mesa-devel \
      ncurses-devel openssl-devel patch procps python python-devel python3-devel \
      readline-devel rsync sed subversion tar libtbb2 tbb-devel unzip wget which \
      libxerces-c-devel xz xz-devel yaml-cpp-devel
zypper clean

# install non system compiler which is needed to compile FairSoft for OpenSuse Leap 15.6
# install newer python3 version which is needed for onnxruntime

zypper install --no-recommends -y gcc14 gcc14-c++ gcc14-fortran python310
rm /usr/bin/python3
ln -s /usr/bin/python3.10 /usr/bin/python3
