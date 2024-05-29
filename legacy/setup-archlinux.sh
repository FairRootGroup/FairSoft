#! /bin/bash

pacman -Sy
pacman -S --noconfirm \
    autoconf automake binutils bison bzip2 ca-certificates cmake coreutils \
    curl diffutils expat fftw findutils flex ftgl gcc gcc-fortran gdbm gettext \
    giflib git gl2ps glew glu gperf grpc grpc-cli gsl gzip help2man hwloc icu \
    libbsd libjpeg-turbo libtiff libtool libunistring libx11 libxau \
    libxdmcp libxext libxfont2 libxft libxml2 libxmu libxpm libxrender \
    lsb-release lz4 m4 make mesa ncurses net-tools openblas openssl patch \
    pkg-config procps protobuf python python-numpy python-pygments python-pyyaml \
    readline rsync sed sqlite subversion tar tbb unzip util-linux-libs wget \
    which xerces-c xz yaml-cpp zstd
pacman -Scc --noconfirm
