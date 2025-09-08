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
* `jan24`, or `nov22p1`, ... - a particular release
* `jan24_patches` - always points to the latest patch release for the `nov22` release
* `master` - track the latest stable release (e.g. if `jan24` is the latest release `master` is the same as `jan24_patches`)
* `dev` - the bleeding edge development version

Discover releases here: https://github.com/FairRootGroup/FairSoft/releases

### 3. CMake configure step

```
cmake -S <path-to-source> -B <path-to-build> -C <path-to-source>/FairSoftConfig.cmake
```

* `<path-to-source>` shall point to the cloned git repo from the previous step
* `<path-to-build>` is a temporary directory of your choice where all of the package download, extraction, and building happens

Set the installation prefix and more customization options in the [`FairSoftConfig.cmake`](../FairSoftConfig.cmake) file itself.

**macOS users**: Notice [macOS SDK](advanced.md#macos-sdk)!

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

| **OS Name** | **Arch** | **OS Version** | **Compiler** | **CMake** |
| --- | --- | --- | --- | --- |
| Fedora     | x86_64 | 38    | GCC 13.2.1                 | 3.27.7 |
| Fedora     | x86_64 | 40    | GCC 14.2.1                 | 3.30.8 |
| Fedora     | x86_64 | 42    | GCC 15.2.1                 | 3.31.6 |
| Debian     | x86_64 | 11    | GCC 10.2.1                 | 4.4.1 (`bootstrap-cmake.sh`) |
| Debian     | x86_64 | 12    | GCC 12.2.0                 | 3.25.1 |
| Open Suse  | x86_64 | 15.6  | GCC 14.3.0 (non system)    | 3.28.3 | 

Not yet tested but know to work with previous FairSoft release.
Will be tested before release

| **OS Name** | **Arch** | **OS Version** | **Compiler** | **CMake** |
| --- | --- | --- | --- | --- |
| Almalinux  | x86_64 | 9     | GCC 11.4.1                 | 3.27.4 (`bootstrap-cmake.sh`) |
| macOS      | x86_64 | 14    | AppleClang 16, gfortran 14 | 3.31.0 (brew) |
| macOS      | x86_64 | 15    | AppleClang 16, gfortran 14 | 3.31.0 (brew) |
| macOS      | arm64  | 15    | AppleClang 16, gfortran 14 | 3.31.0 (brew) |
| Ubuntu     | x86_64 | 22.04 | GCC 11.4.0                 | 3.22.1 |
| Ubuntu     | x86_64 | 24.04 | GCC 13.2.0                 | 3.28.3 |

The additional package **onnxruntime** currently can't be compiled on
Debian10 because of the rather old compiler version. **onnxruntime**
requires at least gcc 11.1 The compilation also fails for OpenSuse Leap 15.6
due to configuration problems. Sine the build system requires at least CMake
3.28 it is needed to install a newer CMake version for Debian12 and
Fedora38. 

## Included packages

| **Package** | **Version** | **URL** |
| --- | --- | --- |
| boost            | 1.87.0       | https://www.boost.org/ |
| clhep            | 2.4.7.1      | http://proj-clhep.web.cern.ch |
| dds              | 3.13         | http://dds.gsi.de |
| faircmakemodules | 1.0.0        | https://github.com/FairRootGroup/FairCMakeModules |
| fairlogger       | 2.2.0        | https://github.com/FairRootGroup/FairLogger |
| fairmq           | 1.9.2        | https://github.com/FairRootGroup/FairMQ |
| flatbuffers      | 23.5.26      | https://github.com/google/flatbuffers |
| fmt              | 11.1.4       | https://github.com/fmtlib/fmt |
| geant3           | 4-4_fairsoft | https://github.com/FairRootGroup/geant3 |
| geant4           | 11.3.2       | https://geant4.web.cern.ch |
| geant4_vmc       | 6-7-p1       | https://github.com/vmc-project/geant4_vmc |
| hepmc            | 2.06.11      | http://hepmc.web.cern.ch |
| onnxruntime      | 1.22.2       | https://github.com/microsoft/onnxruntime |
| pythia8          | 8315         | https://pythia.org/ |
| root             | 6.36.04      | https://root.cern |
| vc               | 1.4.4        | https://github.com/VcDevel/Vc |
| vecgeom          | v.2.0.0-rc.6 | https://gitlab.cern.ch/VecGeom/VecGeom |
| vgm              | 5-3-1        | https://github.com/vmc-project/vgm |
| vmc              | 2-1          | https://github.com/vmc-project/vmc |
| zeromq           | 4.3.5        | https://github.com/zeromq/libzmq |
