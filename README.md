# FairSoft

The FairSoft distribution provides the software packages needed to compile and run the [FairRoot framework](https://github.com/FairRootGroup/FairRoot) and experiment packages based on FairRoot. FairSoft is a source distribution with recurring releases for macOS and Linux (see [platform support](#platform-support)).

## Quick Start

For more control and advanced customization options, see the [next section](#advanced-installation).

### 1. Install the [prerequisites](docs/prerequisites.md).

### 2. Clone the repo

Replace `<release>` with the git branch name or tag of the release you wish to install).

Git `2.12` and older

```
git clone -b <release> --recursive https://github.com/FairRootGroup/FairSoft
```

From Git `2.13` on

```
git clone -b <release> --recurse-submodules https://github.com/FairRootGroup/FairSoft
```

If you checkout a different revision later on in an exisiting FairSoft clone, make sure to run `git submodule update --init` afterwards.

### 3. Compile and Install

Guided

```
FairSoft/configure.py FairSoft_build
cmake --build FairSoft_build --target install
```

or with the standard CMake out-of-source build workflow

```
mkdir FairSoft_build
cd FairSoft_build; cmake -DCMAKE_INSTALL_PREFIX=<where to install> ..; cd ..
cmake --build FairSoft_build --target install
```

The `configure.py` script guides through the various FairSoft specific CMake options as a convenient way to perform the cmake configure step. It exports (and imports) the user choices to (and from) the `CMakeCache.txt` file in the chosen CMake build directory.

## Advanced installation

FairSoft relies on the [Spack package manager](https://spack.io). In Spack terminology, FairSoft is a [Spack package repository](https://spack.readthedocs.io/en/latest/repositories.html) in the [`/packages`](packages) subdirectory within this git repo. This enables us to benefit from the full feature set of Spack. See our [advanced installation guide](docs/advanced.md) for the most important topics including how to

* use your own Spack installation,
* install only a subset of the full FairSoft distro,
* inspect installed software and versions,
* configure/reuse Spack cache and build directories,
* customizing FairSoft (adding/changing packages) for an experiment,

and more.

### Legacy installation method

Older releases prior to REPLACEME utilized a home-grown set of bash-based scripts and install recipes. To smooth the transition to the new Spack-based installation method, we still provide the legacy installation method. In the guided installation just choose the `legacy` installation option. Alternatively, if you are familiar with the old way of installing FairSoft, you can find the old project root in the [`/legacy`](legacy) subdirectory within this git repo.

## Usage on GSI compute farms

TODO

## Contributing

Please ask your questions, request features, and report issues by [creating a github issue](https://github.com/FairRootGroup/FairSoft/issues/new).

See the

## Platform Support

| FairSoft release | Supported platforms |
| --- | --- |
| `dev` | **macOS**: `10.13`, `10.14`, `10.15`</br> **Ubuntu**: `18.04`</br> **Debian**: `8`, `9`, `10`</br> **CentOS**: `7`</br> **Fedora**: `30`, `31` |
