#! /bin/bash

yum -y update
yum -y install centos-release-scl
yum -y install devtoolset-8
yum -y install epel-release
yum -y groupinstall "C Development Tools and Libraries"
yum -y install autoconf automake binutils bison bzip2-devel cmake3 \
ca-certificates coreutils curl-devel diffutils expat-devel findutils flex \
gcc-c++ gcc-gfortran gdbm-devel gettext-devel git gperf gsl-devel \
gzip help2man hostname hwloc-devel m4 make libbsd-devel libtool libicu-devel \
libunistring-devel libuuid-devel libX11-devel libXau-devel \
libXdmcp-devel libXext-devel libXfont-devel libXft-devel libxml2-devel \
libXmu-devel libXpm-devel libXrender-devel lz4-devel make mesa-libGL-devel \
mesa-libGLU-devel ncurses-devel openssl-devel patch procps protobuf-devel \
python python-devel readline-devel redhat-lsb-core sed subversion tar \
tbb-devel unzip wget which xerces-c-devel xz-devel yaml-cpp-devel
yum -y clean all

# This enables devtoolset-8 globally!
profile="/etc/profile.d/enable-devtoolset-8.sh"
cat <<EOF > ${profile}
#!/bin/bash
source scl_source enable devtoolset-8
EOF
chmod a+x "${profile}"

# This enables cmake3 globally!
alternatives --install /usr/local/bin/cmake cmake /usr/bin/cmake3 20 \
--slave /usr/local/bin/ctest ctest /usr/bin/ctest3 \
--slave /usr/local/bin/cpack cpack /usr/bin/cpack3 \
--slave /usr/local/bin/ccmake ccmake /usr/bin/ccmake3 \
--family cmake
