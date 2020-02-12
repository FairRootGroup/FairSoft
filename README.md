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

Inspect the active environment

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

==> 87 installed packages
-- linux-fedora31-skylake / gcc@9.2.1 ---------------------------
binutils@2.32      g4particlexs@1.1         intel-tbb@2019.4      libxft@2.3.2        renderproto@0.11.1
boost@1.68.0       g4photonevaporation@5.3  kbproto@1.0.7         libxml2@2.9.9       rngstreams@1.0.1
bzip2@1.0.8        g4pii@1.3                libbsd@0.9.1          libxpm@3.5.12       root@6.16.00
cmake@3.13.4       g4radioactivedecay@5.3   libedit@3.1-20170329  libxrender@0.9.10   swig@4.0.0
davix@0.6.8        g4realsurface@2.1.1      libevent@2.1.8        llvm@9.0.0          tar@1.32
dds@2.4            g4saiddata@2.0           libice@1.0.9          lz4@1.9.2           unuran@1.8.1
expat@2.2.9        g4tendl@1.3.2            libiconv@1.16         mesa@18.3.6         vc@1.4.1
fairlogger@1.4.0   geant3@v2-7_fairsoft     libpciaccess@0.13.5   mesa-glu@9.0.0      vgm@4-5
fairmq@1.4.3       geant4@10.05.p01         libpng@1.6.37         msgpack-c@3.1.1     xerces-c@3.2.2
fairroot@18.2.1    geant4-data@10.05        libpthread-stubs@0.4  nanomsg@1.1.5       xextproto@7.3.0
font-util@1.3.2    geant4_vmc@4-0-p1        libsm@1.2.2           ncurses@6.1         xproto@7.0.31
fontconfig@2.12.3  gettext@0.20.1           libsodium@1.0.17      nettle@3.4.1        xxhash@0.6.5
freetype@2.10.1    gmp@6.1.2                libuuid@1.0.3         openblas@0.3.7      xz@5.2.4
g4abla@3.1         gnutls@3.6.8             libx11@1.6.7          openssl@1.1.1d      zeromq@4.3.2
g4emlow@7.7        googletest@1.8.1         libxau@1.0.8          pcre@8.42           zlib@1.2.11
g4ensdfstate@2.2   gsl@2.5                  libxcb@1.13           pmix@3.1.3
g4incl@1.0         hepmc@2.06.09            libxdmcp@1.1.2        pythia6@428-alice1
g4ndl@4.5          hwloc@2.0.2              libxext@1.3.3         pythia8@8240
```

### 5. Use

TODO

## [Troubleshooting](docs/troubleshooting.md)

## Structure of this repo

Releases are defined as a Spack environment in the directory [`env/<release>/<variant>.yaml`](env/).

`repo.yaml` + `packages/` constitute the FairSoft Spack package repository.

`config/` contains some general configuration changes needed on some systems, please use it with `spack -C ./config ...`.

`spack/` is a git submodule which references the Spack git repo which currently contains both the Spack software and the Spack builtin package repository. Because some of the packages a FairSoft release pins down come from the Spack builtin repository, the idea is to pin it, too, to provide a reproducible build experience which does not depend on the various possible combination of Spack and FairSoft. The referenced submodule might also contain some extra patches, that we were not yet able to integrate into the upstream Spack itself.

`docs/` contains additional documentation pages, the relevant ones for the user should all be linked from this top-level page.

`legacy/` contains the former shell script based FairSoft before we switched to Spack, it is no longer updated, but remains for reference.

`test/` contains mainly integration test related files used by the FairSoft Continuous Integration checks. The normal user can ignore them.

CMake/CTest-related files are mainly for internal use and running the FairSoft Continuous Integration checks. The normal user can ignore them.

## Contributing

Please ask your questions, request features, and report issues by [creating a github issue](https://github.com/FairRootGroup/FairSoft/issues/new).
