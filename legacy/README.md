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
* `jan24`, or `nov22p1`, ... - a particular release. To get a list of all the available releases use `git tag -l`
* `jan24_patches` - always points to the latest patch release for the `jan24` release
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

#### 3.1 CMake configure step for macOS users

There are some known problems about the compilation of FairSoft on macOS.

The first two problems are related to the version of the **patch** and **make**
commands on macOS.

The **patch** command does not support the needed parameters,
so one needs to install a version of the **patch** command with brew.
The **make** command doesn't properly support the jobsserver which allows
parallel builds of all the packages contained in FairSoft which slows down
the installation enormously. The version provided by brew fixes the problem.
Both packages are already added in the updated setup script for macOS.
If the homebrew version of the packages are available those packages will be used automatically.

The last problem is related to the macOS, compiler and SDK versions, such
that it depends on the personal setup. As described in more detail at
[macOS SDK](advanced.md#macos-sdk)! ROOT is very picky about the compiler
and the connected SDK. Compiling older ROOT versions with newer compilers
may need using an older SDK version. If not specified explicitly the
latest SDK version is used. To use an older SDK version on needs to add the
following parameter when running CMake

```
-DCMAKE_OSX_SYSROOT=<full path to SDK directory>
```

e.g. for Apple Clang 17 on macOs 15 or Apple Clang 16 on macOS 14

```
-DCMAKE_OSX_SYSROOT=/Library/Developer/CommandLineTools/SDKs/MacOSX14.sdk
```

Defining the proper SDK is also needed when compiling **FairRoot** and your **ExperimentRoot**, e.g. **CbmRoot**. Please find more information at [macOS SDK](advanced.md#macos-sdk)!

### 4. CMake build/install step

After a successful CMake configure step, you start the build/install step as follows:

```
cmake --build <path-to-build> [-j<ncpus>]
```

* `<path-to-build>` is the same directory as chosen in the previous configure step
* `-j<ncpus>` parallelize the build. Please specify a value for the number of CPUs otherwise the computer can become completely stuck on some operating systems. 

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
| Debian     | x86_64 | 10    | GCC 8.3.0                             | 3.27.4 (`bootstrap-cmake.sh`) |
| Debian     | x86_64 | 11    | GCC 10.2.1                             | 3.27.4 (`bootstrap-cmake.sh`) |
| Debian     | x86_64 | 12    | GCC 12.2.0                             | 3.25.1 |
| Debian     | x86_64 | 13    | GCC 14.2.0                             | 3.31.6 |
| Fedora     | x86_64 | 38    | GCC 13.2.1                             | 3.27.7 |
| Fedora     | x86_64 | 40    | GCC 14.2.1                             | 3.30.8 |
| Fedora     | x86_64 | 42    | GCC 15.2.1                             | 3.31.6 |
| Fedora     | x86_64 | 43    | GCC 15.2.1                             | 3.31.10 |
| macOS      | x86_64 | 14.8.3 | SDK 14, AppleClang 16, gfortran 15.2.0 | 4.2.3 (`brew`) |
| macOS      | x86_64 | 15.7.2 | SDK 14, AppleClang 17, gfortran 15.2.0 | 4.2.0 (`brew`) |
| macOS      | arm64  | 26.4.1  | SDK 14, AppleClang 21, gfortran 15.2.0 | 4.2.3 (`brew`) |
| OpenSuse   | x86_64 | 15.6  | GCC 14.3.0 (non system)                | 3.28.3 |
| OpenSuse   | x86_64 | 16.0  | GCC 15.1.1                             | 3.31.7 |
| Ubuntu     | x86_64 | 22.04 | GCC 11.4.0                             | 3.22.1 |
| Ubuntu     | x86_64 | 24.04 | GCC 13.3.0                             | 3.28.3 |
| Ubuntu     | x86_64 | 26.04 | GCC 15.2.0                             | 3.31.6 |

The compilation of the optional package **onnxruntime** doesn't work with gcc 13 and gcc 14 probably due to a problem with the STL library used for those versions.
Compilation with earlier and later gcc versions as well as with clang work without errors.

## Included packages

| **Package** | **Version** | **URL** |
| --- | --- | --- |
| boost            | 1.83.0       | https://www.boost.org/ |
| clhep            | 2.4.7.1      | http://proj-clhep.web.cern.ch |
| dds              | 3.8          | http://dds.gsi.de |
| faircmakemodules | 1.0.0        | https://github.com/FairRootGroup/FairCMakeModules |
| fairlogger       | 1.11.1       | https://github.com/FairRootGroup/FairLogger |
| fairmq           | 1.8.4        | https://github.com/FairRootGroup/FairMQ |
| flatbuffers      | 23.5.26      | https://github.com/google/flatbuffers |
| fmt              | 10.1.1       | https://github.com/fmtlib/fmt |
|  geant3           | 4-2_fairsoft | https://github.com/FairRootGroup/geant3 |
| geant4           | 11.2.0       | https://geant4.web.cern.ch |
| geant4_vmc       | 6-5          | https://github.com/vmc-project/geant4_vmc |
| hepmc            | 2.06.11      | http://hepmc.web.cern.ch |
| onnxruntime      | 1.12.1       | https://github.com/microsoft/onnxruntime |
| pythia6          | 428-alice1   | https://github.com/alisw/pythia6 |
| pythia8          | 8310         | https://pythia.org/ |
| root             | 6.30.08      | https://root.cern |
| vc               | 1.4.4        | https://github.com/VcDevel/Vc |
| vgm              | 5-2          | https://github.com/vmc-project/vgm |
| vmc              | 2-0          | https://github.com/vmc-project/vmc |
| zeromq           | 4.3.5        | https://github.com/zeromq/libzmq |
