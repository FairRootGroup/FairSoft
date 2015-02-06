FROM hepsw/slc-base:6.5
MAINTAINER Andrey Ustyuzhanin andrey.ustyuzhanin@cern.ch


RUN yum -y install cmake git gcc-c++ libX11-devel subversion man unzip patch libXpm-devel libXft-devel gcc-gfortran libXext-devel mesa-libGL-devel mesa-libGLU-devel expat-devel libXmu-devel compat-gcc-34-g77 xorg-x11-xauth python-devel bash-completion
RUN rm /usr/lib/gcc/x86_64-redhat-linux/3.4.6/libgcc_s_32.so  # references non-existent file
RUN cp /usr/lib/gcc/x86_64-redhat-linux/3.4.6/lib* /usr/local/lib
# VNC server
RUN yum -y install x11vnc libpng xterm twm
RUN ./auto_config.sh
