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
echo 'config:\n  install_tree: (Choose_Directory)' > $HOME/.spack/config.yaml
```
You can find more configuration options in [Spack documentation](https://spack.readthedocs.io/en/latest/config_yaml.html#config-yaml).

---

Use the following commands in order to setup the spack environment:

```
./spack/bin/spack bootstrap
source spack/share/spack/setup-env.sh
```

---

Add the recepies to the list of spack package repositories:
```
spack repo add .
```
More about spack package repositories is in the [Spack documentation](https://spack.readthedocs.io/en/latest/repositories.html).

---

The following command will install FairRoot release 18.2.1 and its dependencies:
```
spack install fairroot@18.2.1
```

---

In order to load the environment of FairRoot and its dependencies, use the load command of Spack:
```
spack load --dependencies fairroot@18.2.1
```

## Contributing

Please ask your questions, request features, and report issues by [creating a github issue](https://github.com/FairRootGroup/FairSoft/issues/new).
