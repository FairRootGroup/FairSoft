#! /bin/bash

dnf -y update
dnf -y groupinstall "C Development Tools and Libraries"
dnf -y install \
    autoconf automake binutils bison bzip2-devel ca-certificates cmake coreutils curl-devel \
    diffutils expat-devel fftw-devel findutils flex ftgl-devel gcc-c++ gcc-gfortran gdbm-devel \
    gettext-devel giflib-devel git gl2ps-devel glew-devel gperf grpc-cli grpc-devel \
    grpc-plugins gsl-devel gzip help2man hostname hwloc-devel libX11-devel libXau-devel \
    libXdmcp-devel libXext-devel libXfont-devel libXft-devel libXmu-devel libXpm-devel \
    libXrender-devel libbsd-devel libicu-devel libjpeg-turbo-devel libtiff-devel libtool \
    libunistring-devel libuuid-devel libxml2-devel lz4-devel m4 make make mesa-libGL-devel \
    mesa-libGLU-devel ncurses-devel openblas-devel openssl-devel patch procps python \
    python-devel python3-numpy python3-pygments python3-pyyaml readline-devel redhat-lsb-core \
    rsync sed sqlite-devel subversion tar tbb-devel unzip wget which xerces-c-devel xz-devel \
    yaml-cpp-devel
dnf -y clean all
