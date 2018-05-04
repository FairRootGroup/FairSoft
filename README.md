# FairSoft

This repository contain the installation routines of all the external software needed
to compile and use FairRoot.
To simplify the installation procedure of all these packages we provide a set of
scripts which will automatically download, unpack, configure, build‚ and install
all required software.

## Prerequisites

The script needs a complete build environment to compile all the source code. A list
of all needed system packages can be found in the DEPENDENCIES file. All these system
packages are installed using the package manager of the used Linux flavor. A list of
complete command lines to install all packages in one go are also added in the
DEPENDENCIES file, so one only has to cut-n-paste the appropriate command line to a
terminal window and start the installation.

## Tested systems
This Release was tested on following systems:

| System | Version | Compiler|
|---|---|---|
|Debian  | Jessie  | gcc 4.9.2 |
|Ubuntu  | 14.04   | gcc 4.8   |
|Ubuntu  | 16.04   | gcc 5.4   |
|Ubuntu  | 17.04   | gcc 6.3   |
|Ubuntu  | 17.10   | gcc 7.2.0 |
|Cent OS | 7       | gcc 4.8.5 |
|Fedora  | 26      | gcc 7.2.1 |
|MacOs   | El Capitan (10.11.6) | Clang 8.0.0|
|MacOs   | Sierra (10.12.6)     | Clang 8.1.0|
|MacOs   | Sierra (10.12.6)     | Clang 9.0.0|
|MacOs   | High Sierra (10.13)  | Clang 9.0.0|

## Guided Installation

To start the installation procedure one has to run the configure.sh script which is
found in the main directory of FairSoft from within this directory. If the script is
called without parameters one is guided through some menus to choose the appropriate
setup.

  FairSoft> ./configure.sh

In the first menu one has to define the compiler which should be used for the
installation. The normal choices would be _gcc_ for Linux and _Clang_ for Mac OSX.
The compiler must be installed on the system. If one choose a compiler which is not
installed, the installation procedure will stop when checking for the prerequisites
defined above.

In the second menu one has to decide if the packages should be installed in
debug, normal or optimization mode. If one choose the optimization mode one
should also define the correct optimization flags in the file
scripts/check_system.sh, even if there are some default settings.
If unsure don't use the optimization option.

In the third menu you can choose between the usage of ROOT5 and ROOT6. FairRoot running
with ROOT6 has known problems on some Linux flavors, so please use this option
not for your production setup. The new option ROOT6 is only for development and for
testing purposes.

In the forth menu one has to define if one need to install all packages to
run a simulation. If unsure choose _Yes_.

If the previous choice was _Yes_ one has to define in the next menu how to handle the
Geant4 data files. These files have after installation a size of approximately 650 MB.
If you don't intent to use Geant4 you should choose _Don't install_, if unsure choose
one of the other options described below.

If the data files should be installed it is normally save to choose the
option Internet which will download the files and does the installation
automatically when installing Geant4.
Only if your system cannot download the files during installation, choose the
Directory option.  In this case one has to put the files into the transport directory
so that they can be installed. One can download the files from the following webpage.

http://geant4.cern.ch/support/download.shtml

In the next menu one has to decide if the python bindings for Geant4 and Root should
be installed. The python bindings are only needed for the Ship experiment,
so if unsure choose _No_.

In the last menu one has to define the installation directory. All the programs will be
installed into this directory. One shouldn't use as installation directory a directory
which is used by the system (e.g. /usr or /usr/local). Since it is possible to install
several version of "FairSoft" in parallel it is advisable to use a name tag in the
directory name (e.g. <install_dir>/fairsoft_mar15)

After passing all menus the installation process will check if all needed system
packages are installed. If one or more packages are missing the installation process
will stop with an detailed error message. In this case please install the missing
system packages and start the installation again.

The installation procedure may take a long time depending on your computer. If the
installation procedure stops with an error it is save to start the script again.
It will check which packages have been already compilled and installed successfully
and will skip these packages.

## Installation with configuration file

As an alternative for experienced users it is also possible to pass an input file to
the script which defines all the needed information. The configure.sh script will
check if all variables are defined in the input file and if the values are allowed.
In case an error is found the script will stop with an error message. Three example
files (automatic.conf, grid.conf, and recoonly.conf) can be found in the main
directory of FairSoft.

## Included Packages

|Package|Version|
|---|---|
| cmake  |3.11.1 |
| gtest  |1.7.0|
| gsl    |1.16|
| icu4c  |53.1|
| boost  |1_67_0|
| Pythia6 |416|
| HepMC  |2.06.09|
| Pythia8| 212|
| Geant4 |10.04.p01|
| xrootd |4.6.1|
| ROOT | 6.12.06|
| Geant321+_vmc| v2-5|
| VGM| v4-4|
| G4VMC| v3-6|
| MillePede |V04-03-04|
| ZeroMQ |4.2.5|
| Protocoll Buffers| 3.4.0|
| Nano Message |1.0.0|
| FlatBuffers |1.7.1|
| MessagePack |2.1.5|
| DDS |2.0|
| FairMQ |1.2.0|
| FairLogger |1.1.0|
In case the python bindings are build the following additional packages will be installed

* XercesC 3.1.2
* G4Py Version which comes with Geant4


## Removal of packages

The installation script is mainly meant for one time installation of all packages.
For developers we provide also another script which can remove the temporary files
produced during compilation and the installed files for each of the packages.
The script takes care also to delete all other packages which depend on the
package which is removed. As an example given if you remove root then also
geant4, vgm and geant4_vmc will be removed since these packages depend on root.

The skript is either called with one parameter which is the package name

   ./make_clean.sh root

to remove only the temporary files or with the second parameter _all_

  ./make_clean.sh root all

which will also remove the files installed into the installation directory.
