# FairSoft (Legacy)

## Preface

Our classic bash/cmake based setup system
has been named "Legacy". It has been moved to the
sub-directory `legacy/` to distinguish it clearly
from the future Spack-based setup system
(for more information see [here](../docs/README.md)).
The latter will eventually replace the "Legacy" setup system
in a future release.

## System dependencies

Before we start, find the list of required system packages together with instructions
on how to install them in the [dependencies section](dependencies.md).

## Installation

Installing FairSoft is based on the standard CMake workflow with the option to exchange
the command-line based CMake configure step with a menu-guided convenience script.

### 1. Clone the git repo

```
git clone -b <release> https://github.com/FairRootGroup/FairSoft
```

For `<release>` choose
* `nov20`, or `nov20p1`, ... - a particular release
* `nov20_patches` - always points to the latest patch release for the `nov20` release
* `master` - track the latest stable release (e.g. if `nov20` is the latest release `master` is the same as `nov20_patches`)
* `dev` - the bleeding edge development version

Discover releases here: https://github.com/FairRootGroup/FairSoft/releases

### 2. CMake configure step

```
cmake -S <path-to-source> -B <path-to-build> -DCMAKE_INSTALL_PREFIX=<path-to-install>
```

* `<path-to-source>` shall point to the cloned git repo from the previous step
* `<path-to-build>` is a temporary directory of your choice where all of the package download, extraction, and building happens
* `<path-to-install>` is the directory you want all the packages to be installed to

As an alternative to the above command, which is suitable for scripting and comes natural
to the experienced CMake user, you may call the menu-guided convenience script that
will generate and execute the above CMake configure step, just call:

```
FairSoft/configure.sh
```

Find more detailed information on available customization options in the [options section](options.md).

### 3. CMake build/install step

After a successful CMake configure step, you start the build/install step as follows:

```
cmake --build <path-to-build> [-j<ncpus>]
```

* `<path-to-build>` is the same directory as chosen in the previous configure step
* `-j<ncpus>` parallelize the build

Note: Due to technical limitations there is no separate `install` target.

### 4. Usage

```
export SIMPATH=<path-to-install>
```

Simply export an environment variable `SIMPATH` which points to the chosen install directory from step 2
and continue with the [FairRoot installation](https://github.com/FairRootGroup/FairRoot).

## Advanced topics

Find several advanced topics, such as
* where to find the build log,
* the directory layout of the build directory, or
* how to just build a subset of the packages, and more

in the [advanced section](advanced.md).

## Tested systems

The following systems are tested regularly. If you feel your system is missing,
please contact us.

| **System** | **Version** | **Compiler** |
| --- | --- | --- |
| CentOS | 7 | *TBD* |
| CentOS | 8 | *TBD* |
| Debian | 8 (GSI) | GCC 8.1.0 (`/cvmfs/it.gsi.de`) |
| Debian | 10 | GCC 8.3.0 |
| Debian | 11 | *TBD* |
| Fedora | 31 | GCC 9.2.1 |
| Fedora | 32 | GCC 10.2.1 |
| macOS | 10.14 | AppleClang 10.0.1 |
| macOS | 10.15 | AppleClang 12.0.0 |
| OpenSUSE | 15.2 | GCC 7.5.0 |
| Ubuntu | 18.04 | GCC 7.3.0 |
| Ubuntu | 20.04 | GCC 9.3.0 |


## Included Packages

| **Package** | **Version** |
| --- | --- |
| boost | 1.72.0 |
| clhep | 2.4.1.3 |
| dds | 3.5.2 |
| fairlogger | 1.8.0 |
| fairmq | 1.4.25 |
| flatbuffers | 1.12.0 |
| fmt | 6.1.2 |
| geant3 | 3-7_fairsoft |
| geant4 | 10.6.2 |
| geant4_vmc | 5-2 |
| hepmc | 2.06.09 |
| pythia6 | 428-alice1 |
| pythia8 | 8303 |
| root | 6.20.08 |
| vc | 1.4.1 |
| vgm | 4-8 |
| vmc | 1-0-p3 |
| zeromq | 4.3.1 |

## Removal of packages (outdated, move to advanced)

The installation script is mainly meant for one time installation of all packages.
For developers we provide also another script which can remove the temporary files
produced during compilation and the installed files for each of the packages.
The script takes care also to delete all other packages which depend on the
package which is removed. As an example given if you remove root then also
geant4, vgm and geant4_vmc will be removed since these packages depend on root.

The script is either called with one parameter which is the package name

```
FairSoft/legacy$ ./make_clean.sh root
```

to remove only the temporary files or with the second parameter _all_

```
FairSoft/legacy$ ./make_clean.sh root all
```

which will also remove the files installed into the installation directory.
