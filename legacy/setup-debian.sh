#! /bin/bash

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get -y upgrade
apt-get -y install autoconf automake binutils \
	bison build-essential bzip2 ca-certificates coreutils \
	curl debianutils file findutils flex g++ gcc gfortran git gzip \
	hostname libbz2-dev libcurl4-openssl-dev libgsl-dev libicu-dev \
	libgl1-mesa-dev libglu1-mesa-dev libgrpc++-dev \
	libncurses-dev libsqlite3-dev libssl-dev libtool \
	libx11-dev libxerces-c-dev libxext-dev libxft-dev \
	libxml2-dev libxmu-dev libxpm-dev libyaml-cpp-dev lsb-release make patch python-dev \
	python3-dev protobuf-compiler-grpc rsync sed subversion tar unzip wget xutils-dev xz-utils
apt-get -y -t buster-backports install cmake || \
	apt-get -y install cmake
apt-get -y clean
