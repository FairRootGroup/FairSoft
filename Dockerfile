FROM hepsw/slc-base:6.5
MAINTAINER Andrey Ustyuzhanin andrey.ustyuzhanin@cern.ch
ENTRYPOINT ["/bin/sh", "-c", "-l"]
CMD ["bash"]

RUN yum -y install \
	which file bc bash-completion man \
	unzip tar patch \
	cmake \
	gcc-c++ \
	gcc-gfortran \
	compat-gcc-34-g77 \
	git subversion \
	xorg-x11-xauth \
	libX11-devel libXpm-devel libXmu-devel libXft-devel libXext-devel \
	mesa-libGL-devel mesa-libGLU-devel \
	expat-devel \
	python-devel \
	libxml2-devel \
	python-mtTkinter

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
