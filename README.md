# FairSoft

The FairSoft distribution provides the software packages needed to compile and run the [FairRoot framework](https://github.com/FairRootGroup/FairRoot) and experiment packages based on FairRoot. FairSoft is a source distribution with recurring releases for macOS and Linux (see [platform support](#platform-support)).

## Installation

### 1. Install the [prerequisites](docs/prerequisites.md).

### 2. Clone the repo

```
git clone -b <release> https://github.com/FairRootGroup/FairSoft
cd FairSoft
git submodule update --init
```

### 3. Configure Spack

#### Activate Spack in your current shell

```
mkdir -p $HOME/.spack
source spack/share/spack/setup-env.sh
```

#### Configure Spack directories

We recommend to create a [per-user configuration file](https://spack.readthedocs.io/en/latest/config_yaml.html#config-yaml) and point certain paths to a directory outside of the FairSoft source repo:

```
$ mkdir -p $HOME/.spack
$ EDITOR=vim spack config edit config
$ cat $HOME/.spack/config.yaml
config:
  install_tree: ~/.spack/install_tree
  source_cache: ~/.spack/source_cache
```

Verify the config changes are recognized by running `spack config blame config`.

#### Bootstrap Spack

```
spack -C ./config bootstrap
```

#### Add the FairSoft [repository](https://spack.readthedocs.io/en/latest/repositories.html)

```
spack repo add .
```

Verify

```
$ spack repo list
fairsoft    ~/FairSoft
builtin     ~/FairSoft/spack/var/spack/repos/builtin
```

### 4. Compile/Install

The following command will install FairRoot release 18.2.1 and its dependencies:
```
spack -C ./config install fairroot@18.2.1
```

### 5. Use

In order to load the environment of FairRoot and its dependencies, use the load command of Spack:
```
spack load -r fairroot@18.2.1
```

## Contributing

Please ask your questions, request features, and report issues by [creating a github issue](https://github.com/FairRootGroup/FairSoft/issues/new).
