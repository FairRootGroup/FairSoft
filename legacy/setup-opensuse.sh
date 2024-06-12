#! /bin/bash

zypper refresh
zypper update -y
zypper install -y autoconf automake binutils bison bzip2 libbz2-devel cmake \
ca-certificates coreutils curl libcurl-devel diffutils expat libexpat-devel \
fftw-devel findutils flex gcc-c++ gcc-fortran gdbm-devel gettext-devel git gperf gsl-devel \
gzip help2man hostname hwloc hwloc-devel m4 make libbsd-devel libtool libicu-devel \
glu-devel grpc-devel libunistring-devel libuuid-devel libX11-devel libXau-devel \
libXdmcp-devel libXext-devel libXfont-devel libXft-devel libxml2-devel \
libXmu-devel libXpm-devel libXrender-devel liblz4-devel libzstd-devel lsb-release Mesa-devel \
ncurses-devel openssl-devel patch procps python python-devel python3-devel \
readline-devel rsync sed subversion tar libtbb2 tbb-devel unzip wget which \
libxerces-c-devel xz xz-devel yaml-cpp-devel
zypper clean
