#! /bin/bash

dnf -y update
dnf -y groupinstall "C Development Tools and Libraries"
dnf -y install autoconf automake binutils bison bzip2-devel cmake \
ca-certificates coreutils curl-devel diffutils expat-devel findutils flex \
gcc-c++ gcc-gfortran gdbm-devel gettext-devel git gperf gsl-devel grpc-devel grpc-plugins grpc-cli \
gzip help2man hostname hwloc-devel m4 make libbsd-devel libtool libicu-devel \
libunistring-devel libuuid-devel libX11-devel libXau-devel \
libXdmcp-devel libXext-devel libXfont-devel libXft-devel libxml2-devel \
libXmu-devel libXpm-devel libXrender-devel lz4-devel make mesa-libGL-devel \
mesa-libGLU-devel ncurses-devel openssl-devel patch procps \
python python-devel readline-devel redhat-lsb-core sed subversion tar \
tbb-devel unzip wget which xerces-c-devel xz-devel yaml-cpp-devel
dnf -y clean all
