FROM hepsw/slc-base:6.5
MAINTAINER Andrey Ustyuzhanin andrey.ustyuzhanin@cern.ch
ENTRYPOINT ["/bin/sh", "-c", "-l"]
CMD ["bash"]

RUN yum -y install which tar subversion file bc
RUN yum -y install cmake git gcc-c++ libX11-devel subversion man unzip patch libXpm-devel libXft-devel gcc-gfortran libXext-devel mesa-libGL-devel mesa-libGLU-devel expat-devel libXmu-devel compat-gcc-34-g77 xorg-x11-xauth python-devel bash-completion
RUN rm /usr/lib/gcc/x86_64-redhat-linux/3.4.6/libgcc_s_32.so  # references non-existent file
RUN cp /usr/lib/gcc/x86_64-redhat-linux/3.4.6/lib* /usr/local/lib
# VNC server
RUN yum -y install x11vnc libpng xterm twm
ENV SHIPSOFT /opt/ocean
ENV FAIRROOTPATH $SHIPSOFT/FairRootInst
ENV SIMPATH $SHIPSOFT/FairSoftInst
ENV FAIRSHIP /opt/ship/FairShip
#ENV FAIRSHIP_BLD $FAIRSHIP/build
ENV PYTHONPATH $FAIRSHIP/python:$SIMPATH/lib:$SIMPATH/lib/Geant4

#export FAIRSHIP=$SHIPSOFT/FairShip
#export FAIRSHIPRUN=$SHIPSOFT/FairShipRun

RUN mkdir /tmp/FairShip
COPY . /tmp/FairShip
WORKDIR /tmp/FairShip
RUN ./auto_build.sh
# RUN rm -rf /tmp/FairShip
