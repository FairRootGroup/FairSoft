# FairSoft

The FairSoft distribution provides the software packages needed to compile and run the [FairRoot framework](https://github.com/FairRootGroup/FairRoot) and experiment packages based on FairRoot. FairSoft is a source distribution with recurring releases for macOS and Linux (see [platform support](#platform-support)).

## Installation

For more control and advanced customization options, see the [next section](#advanced-installation).

### 1. Install the [prerequisites](docs/prerequisites.md).

### 2. Clone the repo

```
git clone -b <release> https://github.com/FairRootGroup/FairSoft
cd FairSoft
git submodule update --init
```

### 3. Compile and Install

By default, the packages will be installed into spack/opt/spack folder. In order to change the installation prefix, one can set install_tree variable in the per-user configuration file as follows:
```
mkdir -p $HOME/.spack
echo -e 'config:\n  install_tree: (Choose_Directory)' > $HOME/.spack/config.yaml
```
You can find more configuration options in [Spack documentation](https://spack.readthedocs.io/en/latest/config_yaml.html#config-yaml).

---

Use the following commands in order to setup the spack environment:

```
./spack/bin/spack -C ./config bootstrap
. ./spack/share/spack/setup-env.sh
```

---

Add the recepies to the list of spack package repositories:
```
spack repo add .
```
More about spack package repositories is in the [Spack documentation](https://spack.readthedocs.io/en/latest/repositories.html).

---

Following commands will create a Spack environment from the specified configuration file, activate this environment
and install FairRoot and its dependencies:
```
spack -C env create jun19 env/jun19/sim_python_threads.yaml
spack -C env activate jun19
spack -C ./config install
```
The environment needs to be activated in every shell. One can deactivate the environemnt with command:
```
spack env deactivate
```
or
```
despacktivate
```
More about environments can be found in [Spack documentation](https://spack.readthedocs.io/en/latest/environments.html).

---

In order to set the environment variables needed for FairRoot and its dependencies, use the load command of Spack:
```
spack load -r fairroot@18.2.1
```

### 4. Create view

As an alternative to loading fairroot and its dependencies into the environment, one can create a view.
View is a directory where links to all packages are put together. This directory can be used as SIMPATH
in order to compile experiment frameworks.
```
spack -C ./config view --verbose --dependencies true -e python symlink -i (YOUR_SIMPATH) fairroot@18.2.1
```
In case you are using macOS, following packages need to be skipped when creating a view:
macOS 10.14 Mojave: -e libiconv -e libpng -e sqlite
macOS 10.15 Catalina: -e libiconv

### 5. Development build

You can use spack for building a package in the development mode: not checking out from repository, but building
the source code in local path.
```
spack -C ./config diy -j (NUMBER_OF_PARALLEL_JOBS) -d (PATH_TO_SOURCE) fairroot@18.2.1
```
The version number of the package in this command is mandatory.

## Contributing

Please ask your questions, request features, and report issues by [creating a github issue](https://github.com/FairRootGroup/FairSoft/issues/new).
