#! /bin/bash

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get -y upgrade
apt-get -y install autoconf automake binutils \
	bison build-essential bzip2 ca-certificates coreutils \
	curl debianutils file findutils flex g++ gcc gfortran git gzip \
	hostname libbz2-dev libcurl4-openssl-dev libgsl-dev libicu-dev \
	libfftw3-dev \
	libgl1-mesa-dev libglu1-mesa-dev libgrpc++-dev \
	libncurses-dev libreadline-dev libsqlite3-dev libssl-dev libtbb-dev libtool \
	libx11-dev libxerces-c-dev libxext-dev libxft-dev \
	libxml2-dev libxmu-dev libxpm-dev libyaml-cpp-dev libzstd-dev lsb-release make patch \
	python3-dev protobuf-compiler-grpc rsync sed subversion tar unzip wget xutils-dev xz-utils
apt-get -y -t buster-backports install cmake || \
	apt-get -y install cmake

OS_VERSION=$(cat /etc/os-release  | grep VERSION_ID | cut -f2 -d\")
if [ $OS_VERSION -ge 12 ]; then
  apt-get -y install libxrootd-server-dev libxrootd-private-dev
fi

apt-get -y clean
