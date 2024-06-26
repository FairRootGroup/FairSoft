#! /bin/bash

dnf -y update
dnf -y install dnf-plugins-core epel-release
dnf -y upgrade
dnf config-manager --set-enabled powertools || dnf config-manager --enable crb
dnf -y update
dnf -y install \
    autoconf automake binutils bison bzip2-devel ca-certificates cmake coreutils-single curl-devel \
    diffutils expat-devel fftw-devel findutils flex ftgl-devel gcc-c++ gcc-gfortran gdbm-devel \
    gettext-devel giflib-devel git gl2ps-devel glew-devel gperftools gsl-devel gzip help2man \
    hostname hwloc-devel libX11-devel libXau-devel libXdmcp-devel libXext-devel libXfont2-devel \
    libXft-devel libXmu-devel libXpm-devel libXrender-devel libbsd-devel libicu-devel libjpeg-turbo-devel \
    libtiff-devel libtool libunistring-devel libuuid-devel libxml2-devel libzstd-devel lz4-devel \
    m4 make make mesa-libGL-devel mesa-libGLU-devel ncurses-devel openssl-devel patch pcre-devel \
    procps python3 python3-devel python3-numpy python3-pyyaml readline-devel lsb_release \
    rsync sed sqlite-devel subversion tar tbb-devel unzip wget which xerces-c-devel xxhash-devel \
    xz-devel yaml-cpp-devel zstd protobuf-devel python-unversioned-command
alternatives --set python /usr/bin/python3 || /usr/bin/true
dnf -y clean all
