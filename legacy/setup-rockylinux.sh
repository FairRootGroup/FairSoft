#! /bin/bash

dnf -y update
dnf -y install dnf-plugins-core epel-release
dnf -y upgrade
dnf config-manager --set-enabled powertools
dnf -y update
dnf -y install autoconf automake binutils bison bzip2-devel cmake \
ca-certificates coreutils-single curl-devel diffutils expat-devel findutils flex \
gcc-c++ gcc-gfortran gdbm-devel gettext-devel git gperftools gsl-devel \
gzip help2man hostname hwloc-devel m4 make libbsd-devel libtool libicu-devel \
libunistring-devel libuuid-devel libX11-devel libXau-devel \
libXdmcp-devel libXext-devel libXfont2-devel libXft-devel libxml2-devel \
libXmu-devel libXpm-devel libXrender-devel lz4-devel make mesa-libGL-devel \
mesa-libGLU-devel ncurses-devel openssl-devel patch procps \
python39 python39-devel readline-devel redhat-lsb-core rsync sed subversion tar \
tbb-devel unzip wget which xerces-c-devel xz-devel yaml-cpp-devel
alternatives --set python /usr/bin/python3
dnf -y clean all
