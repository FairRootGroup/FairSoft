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
* `feb26`, or `jan24p6`, ... - a particular release
* `feb26_patches` - always points to the latest patch release for the `feb26` release
* `master` - track the latest stable release (e.g. if `feb26` is the latest release `master` is the same as `feb26_patches`)
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
If found the packages from the homebrew installation directory will be used.

The last problem is related to the macOS, compiler and SDK versions, such
that it depends on the personal setup. As described in more detail at
[macOS SDK](advanced.md#macos-sdk)! ROOT is very picky about the compiler
and the connected SDK. Compiling older ROOT versions with newer compilers
may need using an older SDK version. If not specified explicitly the
latest SDK version is used. To use an older SDK version one needs to add the
following parameter when running CMake

```
-DCMAKE_OSX_SYSROOT=<full path to SDK directory>
```

e.g. for Apple Clang 17 on macOS 15 or Apple Clang 16 on macOS 14

```
-DCMAKE_OSX_SYSROOT=/Library/Developer/CommandLineTools/SDKs/MacOSX14.sdk
```

More information can be found at

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
| Debian     | x86_64 | 12    | GCC 12.2.0                             | 3.25.1 |
| Debian     | x86_64 | 12    | GCC 12.2.0                             | 4.2.3 (bootstrap) |
| Debian     | x86_64 | 13    | GCC 14.2.0                             | 3.31.6 |
| Fedora     | x86_64 | 38    | GCC 13.2.1                             | 3.27.7 |
| Fedora     | x86_64 | 38    | GCC 13.2.1                             | 4.2.3 (bootstrap) |
| Fedora     | x86_64 | 40    | GCC 14.2.1                             | 3.30.8 |
| Fedora     | x86_64 | 42    | GCC 15.2.1                             | 3.31.6 |
| Fedora     | x86_64 | 43    | GCC 15.2.1                             | 3.31.10 |
| macOS      | x86_64 | 15    | SDK 26, AppleClang 17, gfortran 15.2.0 | 4.2.0 (brew) |
| macOS      | arm64  | 26    | SDK 26, AppleClang 17, gfortran 15.2.0 | 4.2.3 (brew) |
| macOS      | arm64  | 26    | SDK 14, AppleClang 17, gfortran 15.2.0 | 4.2.3 (brew) |
| OpenSuse   | x86_64 | 15.6  | GCC 14.3.0 (non system)                | 3.28.3 |
| OpenSuse   | x86_64 | 16.0  | GCC 15.1.1                             | 3.31.7 |
| Ubuntu     | x86_64 | 22.04 | GCC 11.4.0                             | 4.2.3 (bootstrap) |
| Ubuntu     | x86_64 | 24.04 | GCC 13.3.0                             | 3.28.3 |
| Ubuntu     | x86_64 | 26.04 | GCC 15.2.0                             | 3.31.6 |

## Included packages

| **Package** | **Version** | **URL** |
| --- | --- | --- |
| boost            | 1.90.0       | https://www.boost.org/ |
| clhep            | 2.4.7.2      | http://proj-clhep.web.cern.ch |
| dds              | 3.16         | http://dds.gsi.de |
| faircmakemodules | 1.0.0        | https://github.com/FairRootGroup/FairCMakeModules |
| fairlogger       | 2.3.1        | https://github.com/FairRootGroup/FairLogger |
| fairmq           | 1.10.1       | https://github.com/FairRootGroup/FairMQ |
| flatbuffers      | 25.12.19     | https://github.com/google/flatbuffers |
| fmt              | 12.1.0       | https://github.com/fmtlib/fmt |
| geant3           | 4-5_fairsoft | https://github.com/FairRootGroup/geant3 |
| geant4           | 11.4.0       | https://geant4.web.cern.ch |
| geant4_vmc       | 6-8          | https://github.com/vmc-project/geant4_vmc |
| hepmc            | 2.06.11      | http://hepmc.web.cern.ch |
| onnxruntime      | 1.24.1       | https://github.com/microsoft/onnxruntime |
| pythia8          | 8317         | https://pythia.org/ |
| root             | 6.36.08      | https://root.cern |
| vc               | 1.4.5        | https://github.com/VcDevel/Vc |
| vecgeom          | 2.0.0        | https://gitlab.cern.ch/VecGeom/VecGeom |
| vgm              | 5-4          | https://github.com/vmc-project/vgm |
| vmc              | 2-1          | https://github.com/vmc-project/vmc |
| zeromq           | 4.3.5        | https://github.com/zeromq/libzmq |

 
The additional packages **onnxruntime** and **dds** can't be compiled with
the standard CMake versions of Debian 12 and Fedora 38. A newer CMake version
can be installed using the script legacy/bootstrap-cmake.sh which is part
of the repository.
