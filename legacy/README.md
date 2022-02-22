# FairSoft (Legacy)

Table of Contents
* [Preface](#preface)
* [Installation from source](#installation-from-source)
* [Advanced topics and troubleshooting](#advanced-topics)
* [Tested systems](#tested-systems)
* [Included packages](#included-packages)

## Preface

Our classic bash/cmake based setup system
has been named "Legacy". It has been moved to the
sub-directory `legacy/` to distinguish it clearly
from the future Spack-based setup system
(for more information see [here](../docs/README.md)).
The latter will eventually replace the "Legacy" setup system
in a future release.

## Installation from source

Installing FairSoft is based on the standard CMake workflow.

### 1. Install system dependencies

Find the list of required system packages together with instructions
on how to install them in the [dependencies section](dependencies.md).

### 2. Clone the git repo

```
git clone -b <release> https://github.com/FairRootGroup/FairSoft
```

For `<release>` choose
* `aug21`, or `aug21p1`, ... - a particular release
* `aug21_patches` - always points to the latest patch release for the `aug21` release
* `master` - track the latest stable release (e.g. if `aug21` is the latest release `master` is the same as `aug21_patches`)
* `dev` - the bleeding edge development version

Discover releases here: https://github.com/FairRootGroup/FairSoft/releases

### 3. CMake configure step

```
cmake -S <path-to-source> -B <path-to-build> -C <path-to-source>/FairSoftConfig.cmake
```

* `<path-to-source>` shall point to the cloned git repo from the previous step
* `<path-to-build>` is a temporary directory of your choice where all of the package download, extraction, and building happens

Set the installation prefix and more customization options in the [`FairSoftConfig.cmake`](../FairSoftConfig.cmake) file itself.

### 4. CMake build/install step

After a successful CMake configure step, you start the build/install step as follows:

```
cmake --build <path-to-build> [-j<ncpus>]
```

* `<path-to-build>` is the same directory as chosen in the previous configure step
* `-j<ncpus>` parallelize the build

### 5. Usage

```
export SIMPATH=<path-to-install>
```

Simply export an environment variable `SIMPATH` which points to the chosen install directory from step 2
and continue with the [FairRoot installation](https://github.com/FairRootGroup/FairRoot).

## Advanced topics

Find several advanced and troubleshooting topics in the [advanced section](advanced.md).

## Tested systems

The following systems are tested regularly. If you feel your system is missing,
please contact us.

| **System** | **Version** | **Compiler** | **CMake** |
| --- | --- | --- | --- |
| CentOS | 7 | GCC 7.3.1 (devtoolset-7) | 3.17.3 (epel: cmake3) |
| Rockylinux | 8 | GCC 8.5.0 | 3.20.2 |
| Debian | 10 | GCC 8.3.0 | 3.18.3 (`bootstrap-cmake.sh`) |
| Debian | 11 | GCC 10.2.1 | 3.18.4 |
| Fedora | 33 | GCC 10.3.1 | 3.19.7 |
| Fedora | 34 | GCC 11.2.1 | 3.20.5 |
| Fedora | 35 | GCC 11.2.1 | 3.22.1 |
| macOS | 10.15 | AppleClang 12.0, gfortran 11.2.0 | 3.22.1 (brew) |
| macOS | 11 | AppleClang 12.0, gfortran 11.2.0 | 3.22.1 (brew) |
| OpenSUSE | 15.2 | GCC 7.5.0 | 3.17.0 |
| Ubuntu | 20.04 | GCC 9.3.0 | 3.16.3 |

## Included packages

| **Package** | **Version** | **URL** |
| --- | --- | --- |
| asio             | 1.19.1       | https://think-async.com/Asio/ |
| boost            | 1.76.0       | https://www.boost.org/ |
| clhep            | 2.4.5.1      | http://proj-clhep.web.cern.ch |
| dds              | 3.6          | http://dds.gsi.de |
| faircmakemodules | 1.0.0        | https://github.com/FairRootGroup/FairCMakeModules |
| fairlogger       | 1.9.3        | https://github.com/FairRootGroup/FairLogger |
| fairmq           | 1.4.44       | https://github.com/FairRootGroup/FairMQ |
| flatbuffers      | 1.12.0       | https://github.com/google/flatbuffers |
| fmt              | 7.1.3        | https://github.com/fmtlib/fmt |
| geant3           | 3-9_fairsoft | https://github.com/FairRootGroup/geant3 |
| geant4           | 10.7.1       | https://geant4.web.cern.ch |
| geant4_vmc       | 6-0          | https://github.com/vmc-project/geant4_vmc |
| hepmc            | 2.06.11      | http://hepmc.web.cern.ch |
| odc              | 0.62         | https://github.com/FairRootGroup/ODC |
| pythia6          | 428-alice1   | https://github.com/alisw/pythia6 |
| pythia8          | 8303         | https://pythia.org/ |
| root             | 6.24.06      | https://root.cern |
| vc               | 1.4.2        | https://github.com/VcDevel/Vc |
| vgm              | 5-0          | https://github.com/vmc-project/vgm |
| vmc              | 2-0          | https://github.com/vmc-project/vmc |
| zeromq           | 4.3.4        | https://github.com/zeromq/libzmq |
