# FairSoft

The FairSoft distribution provides the software packages needed to compile and run the [FairRoot framework](https://github.com/FairRootGroup/FairRoot) and experiment packages based on FairRoot. FairSoft is a source distribution with recurring releases for macOS and Linux.

## Installation

### 1. Install the [prerequisites](docs/prerequisites.md).

### 2. Clone the repo

```
git clone https://github.com/FairRootGroup/FairSoft
cd FairSoft
git submodule update --init
```

Remember to run `git submodule update --init` even after you checked out a new branch or tag in an existing repository clone!

### 3. Configure Spack

#### Activate Spack in your current shell

```
source spack/share/spack/setup-env.sh
```

#### Configure Spack directories

We recommend to create a [per-user configuration file](https://spack.readthedocs.io/en/latest/config_yaml.html#config-yaml) and point certain paths to a directory outside of the FairSoft source repo because these directories can grow quite large:

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

#### Define a [spack environment](https://spack.readthedocs.io/en/latest/environments.html) for a FairSoft release

```
spack env create jun19 env/jun19/sim_threads.yaml
```

`jun19` can be any name you choose. Verify

```
$ spack env list
==> 1 environments
    jun19
```

#### Activate the [spack environment](https://spack.readthedocs.io/en/latest/environments.html)

In order to work with the previously defined environment, it needs to be activated in any given shell instance

```
spack env activate jun19
```

Verify

```
$ spack env status
==> In environment jun19
```

You may also activate an environment with `-p` which generates a prefix to your prompt as long as the environment is active

```
$ spack env activate -p jun19
[jun19] $
```

To deactive the active environment, run
```
spack env deactivate
```
or
```
despacktivate
```

#### Compile and install the packages defined in the active [spack environment](https://spack.readthedocs.io/en/latest/environments.html)

Under an active spack environment run
```
$ spack env activate -p jun19
[jun19] $ spack find
==> In environment jun19
==> Root specs
boost@1.68.0
cmake@3.13.4
dds@2.4
fairlogger@1.4.0
fairmq@1.4.3
fairroot@18.2.1 +sim
geant3@v2-7_fairsoft
geant4@10.05.p01 ~clhep~data~motif~opengl~qt+threads~vecgeom~x11
geant4_vmc@4-0-p1
googletest@1.8.1
hepmc@2.06.09  length=CM momentum=GEV
pcre +jit
pythia6@428-alice1
pythia8@8240
root@6.16.00 +fortran+gdml+http+memstat+pythia6+pythia8~python~tmva+vc~vdt
vgm@4-5

==> 0 installed packages
```

The `jun19` FairSoft release pins certain package version and build variants that have been carefully chosen to work well together. To install the packages in the environment run

```
[jun19] $ spack -C ./config install
```

This step usually takes a while - time for a coffee break ☕.

Verify the installation

```
[jun19] $ spack find
```
TODO

### 5. Use

TODO

## Contributing

Please ask your questions, request features, and report issues by [creating a github issue](https://github.com/FairRootGroup/FairSoft/issues/new).
