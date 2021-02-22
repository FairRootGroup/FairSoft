# FairSoft (Legacy)

Table of Contents
* [Preface](#preface)
* [Installation from source](#installation-from-source)
* [Installation with package manager](#installation-with-package-manager)
* [Advanced topics and troubleshooting](#advanced-topics-and-troubleshooting)
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
* `nov20`, or `nov20p1`, ... - a particular release
* `nov20_patches` - always points to the latest patch release for the `nov20` release
* `master` - track the latest stable release (e.g. if `nov20` is the latest release `master` is the same as `nov20_patches`)
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

## Installation with package manager

At this point in time, we provide a FairSoft package for macOS only based on [Homebrew](https://brew.sh/):

As preparation run

```
brew update
brew doctor
```

Address all issues found by `brew doctor` until you get the message `Your system is ready to brew.`.
If you choose to not update your system and your Xcode installations to the latest releases, package
installation may still succeed but may have to fall back to compile from source.

```
brew tap fairrootgroup/fairsoft
brew install fairsoft@20.11
```

Note: Due to technical limitations the version numbers of the brew formula are converted to numerical
dot notation, e.g. `20.11` for `nov20`.

You may then use this package by setting the `SIMPATH` environment variable:

```
export SIMPATH=$(brew --prefix fairsoft@20.11)
```

The brew package reflects FairSoft in its default configuration - for details, find the formula in
[https://github.com/FairRootGroup/homebrew-fairsoft](https://github.com/FairRootGroup/homebrew-fairsoft).
It is currently not planned to provide other precompiled configurations.

## Advanced topics

Find several advanced and troubleshooting topics in the [advanced section](advanced.md).

## Tested systems

The following systems are tested regularly. If you feel your system is missing,
please contact us.

| **System** | **Version** | **Compiler** | **CMake** |
| --- | --- | --- | --- |
| CentOS | 7 | GCC 7.3.1 (devtoolset-7) | 3.17.3 (epel: cmake3) |
| Debian | 10 | GCC 8.3.0 | 3.18.3 (`bootstrap-cmake.sh`) |
| Fedora | 33 | GCC 10.2.1 | 3.18.3 |
| macOS | 10.15 | AppleClang 12.0 | 3.18.4 (brew) |
| macOS | 11.0 | AppleClang 12.0 | 3.19.0 (brew) |
| OpenSUSE | 15.2 | GCC 7.5.0 | 3.17.0 |
| Ubuntu | 20.04 | GCC 9.3.0 | 3.16.3 |

## Included packages

| **Package** | **Version** | **URL** |
| --- | --- | --- |
| boost | 1.72.0 | https://www.boost.org/ |
| clhep | 2.4.4.0 | http://proj-clhep.web.cern.ch |
| dds | 3.5.3 | http://dds.gsi.de |
| fairlogger | 1.9.0 | https://github.com/FairRootGroup/FairLogger |
| fairmq | 1.4.26 | https://github.com/FairRootGroup/FairMQ |
| flatbuffers | 1.12.0 | https://github.com/google/flatbuffers |
| fmt | 6.1.2 | https://github.com/fmtlib/fmt |
| geant3 | 3-7_fairsoft | https://github.com/FairRootGroup/geant3 |
| geant4 | 10.7.0 | https://geant4.web.cern.ch |
| geant4_vmc | 5-3 | https://github.com/vmc-project/geant4_vmc |
| hepmc | 2.06.11 | http://hepmc.web.cern.ch |
| odc | 0.10 | https://github.com/FairRootGroup/ODC |
| pythia6 | 428-alice1 | https://github.com/alisw/pythia6 |
| pythia8 | 8303 | http://home.thep.lu.se/~torbjorn/pythia8 |
| root | 6.22.06 | https://root.cern |
| vc | 1.4.1 | https://github.com/VcDevel/Vc |
| vgm | 4-8 | https://github.com/vmc-project/vgm |
| vmc | 1-0-p3 | https://github.com/vmc-project/vmc |
| zeromq | 4.3.2 | https://github.com/zeromq/libzmq |
