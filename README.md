# FairSoft

The FairSoft distribution provides the software packages needed to compile and run the [FairRoot framework](https://github.com/FairRootGroup/FairRoot) and experiment packages based on FairRoot. FairSoft is a source distribution with recurring releases for macOS and Linux.

The newly released FairSoft modernizes and reorganizes the framework installation.
All needed packages, including the FairRoot package itself,
are now installed using [Spack](https://spack.readthedocs.io/en/latest/).

The packages are installed by Spack automatically using package [recipes](https://spack-tutorial.readthedocs.io/en/latest/tutorial_packaging.html), stored in the corresponding folders of the [packages](./repos/fairsoft/packages) directory. The [recipe](https://spack-tutorial.readthedocs.io/en/latest/tutorial_packaging.html)
lists the dependencies of the given package and describes its installation procedure. A collection of packages that form the software framework is called [spack environment](https://spack.readthedocs.io/en/latest/environments.html)  - examples of such are located in the [env](./env) directories.

In the process of installing of a package, Spack creates its list of dependencies,
forming the so-called installation tree. It is possible to install different packages/versions with [Spack](https://spack.readthedocs.io/en/latest/). Since they share a common installation tree, the Spack reuses already available software when installing new package.


The following document is divided into:
* [I. Preparation](#i-preparation) (download the package)
* [II. Installation](#ii-installation) (install packages in environment)
* [III. Execution](#iii-execution) (using the framework)
* [IV. Development](#iv-development)
* [V. Troubleshooting](#v-troubleshooting)
* [VI. Advanced topics](#vi-advanced-topics)

---

## I. Preparation

### I.1. Install the [prerequisites](docs/prerequisites.md).

### I.2. Clone the repo
```
git clone https://github.com/FairRootGroup/FairSoft
cd FairSoft
git submodule update --init
```

### I.3. Run the setup

```
$ source thisfairsoft.sh --setup
==> Added 1 new compiler to /home/user/.spack/linux/compilers.yaml
    gcc@8.3.0
==> Compilers are defined in the following files:
    /home/user/.spack/linux/compilers.yaml
==> Added repo with namespace 'fairsoft_backports'.
==> Added repo with namespace 'fairsoft'.
==> Removing all temporary build stages
==> Removing cached information on repositories
```

You should run the `--setup` step after a new checkout, or after switching to a new branch, tag.

Notes:
* This sets up a lot of things again.
  * It even calls `git submodule update --init`.
* Be a bit careful. Especially do not call this when you expect other spack operations to happen in parallel.
* This can be used to clean up some mild mess (used to fix some problems, that we experienced)
  * It calls `spack clean` with some useful options.


### I.4. Activate Spack in your current shell

Only needed in new shells where you have not just performed the previous step.

```
source thisfairsoft.sh
```

Verify that the `spack` command works and lists the correct FairSoft package [repository](https://spack.readthedocs.io/en/latest/repositories.html).

```
$ spack repo list
==> 3 package repositories.
fairsoft              ~/FairSoft/repos/fairsoft
fairsoft_backports    ~/FairSoft/repos/fairsoft-backports
builtin               ~/FairSoft/spack/var/spack/repos/builtin
```

## II. Installation

### II.1. Define a [spack environment](https://spack.readthedocs.io/en/latest/environments.html) for a FairSoft release

```
spack env create jun19 env/jun19/sim/spack.yaml
```

`jun19` can be any name you choose. Verify

```
$ spack env list
==> 1 environments
    jun19
```

### II.2. Activate the Spack environment

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

### II.3. Compile and install the packages defined in the active [spack environment](https://spack.readthedocs.io/en/latest/environments.html)

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
geant3@2-7_fairsoft
geant4@10.05.p01 ~clhep~data~motif~opengl~qt+threads~vecgeom~x11
geant4-vmc@4-0-p1
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
[jun19] $ spack install
```

This step usually takes a while - time for a coffee break ☕.

### II.4. Verify the installation

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
geant3@2-7_fairsoft
geant4@10.05.p01 ~clhep~data~motif~opengl~qt+threads~vecgeom~x11
geant4-vmc@4-0-p1
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
fairlogger@1.4.0   geant3@2-7_fairsoft      libpciaccess@0.13.5   mesa-glu@9.0.0      vgm@4-5
fairmq@1.4.3       geant4@10.05.p01         libpng@1.6.37         msgpack-c@3.1.1     xerces-c@3.2.2
fairroot@18.2.1    geant4-data@10.05        libpthread-stubs@0.4  nanomsg@1.1.5       xextproto@7.3.0
font-util@1.3.2    geant4-vmc@4-0-p1        libsm@1.2.2           ncurses@6.1         xproto@7.0.31
fontconfig@2.12.3  gettext@0.20.1           libsodium@1.0.17      nettle@3.4.1        xxhash@0.6.5
freetype@2.10.1    gmp@6.1.2                libuuid@1.0.3         openblas@0.3.7      xz@5.2.4
g4abla@3.1         gnutls@3.6.8             libx11@1.6.7          openssl@1.1.1d      zeromq@4.3.2
g4emlow@7.7        googletest@1.8.1         libxau@1.0.8          pcre@8.42           zlib@1.2.11
g4ensdfstate@2.2   gsl@2.5                  libxcb@1.13           pmix@3.1.3
g4incl@1.0         hepmc@2.06.09            libxdmcp@1.1.2        pythia6@428-alice1
g4ndl@4.5          hwloc@2.0.2              libxext@1.3.3         pythia8@8240
```

## III. Execution

### III.1. Spack view

Symbolic links to packages in install tree can be placed to a common installation prefix using view command.
This will create a directory, which can be used as SIMPATH and FAIRROOTPATH in order to build experiment-specific frameworks.
View is created by following command:

Linux
```
[jun19] $ spack view --dependencies true symlink -i (YOUR_SIMPATH) fairroot
```

macOS
```
[jun19] $ spack view --dependencies true -e libpng -e libjpeg-turbo -e libiconv -e sqlite symlink -i (YOUR_SIMPATH) fairroot
```

The view creation has to be done within an [activated environment](#iii2-activate-the-spack-environment).

### III.2. Spack load (beta)

As an alternative to the view the Spack offers the [module mechanism](https://spack.readthedocs.io/en/latest/module_file_support.html), allowing the user to set the running environment using the load command:

```
[jun19] $ spack load --dependencies fairroot
```

This will set the corrects paths to run the environment.

__This functionally is not yet fully supported.__

## IV. Development

### IV.1. Classic "cmake -> make -> make install" workflow (FairRoot and/or Experiment)

```
[jun19] $ export SIMPATH=<path of your choice>
[jun19] $ spack view --dependencies true [-e fairroot] symlink -i $SIMPATH fairroot [cmake]
```

The above will create a directory structure at the path of your choice that can be used as
* $SIMPATH - with `-e fairroot`, or
* $SIMPATH and $FAIRROOTPATH - without `-e fairroot`.

If you need a newer CMake version than your system provides, add `cmake` at the end of the `spack view` command which will make a recent version available at `$SIMPATH/bin/cmake`.

A $SIMPATH created as shown above may be removed by a simple `rm -rf $SIMPATH`. This will **not** uninstall the packages themselves and you may recreate the view without recompilation.

### IV.2. Spack dev-build (single-package)

A package can be built in development mode - without checking it out from repository. In this case the code will be taken from local directory SOURCE_PATH.
Following command will run development build of FairRoot with dependencies equivalent to jun19 environemnt on macOS. Currently this has to be configured manually.

```
spack dev-build -j JOBS -d SOURCE_PATH fairroot@18.2.1+sim+examples ^pcre+jit ^python@2.7.16 ^py-numpy@1.16.5 ^googletest@1.8.1 ^boost@1.68.0 ^fairlogger@1.4.0 \
^dds@2.4 ^fairmq@1.4.3 ^pythia6@428-alice1 ^hepmc@2.06.09 length=CM momentum=GEV ^pythia8@8240 ^geant4@10.05.p01~qt~vecgeom~opengl~x11~motif~data~clhep~threads \
^root@6.16.00+fortran+gdml+memstat+pythia6+pythia8+vc~vdt+python+tmva+xrootd+aqua ^geant3@2-7_fairsoft ^vgm@4-5 ^geant4-vmc@4-0-p1
```

## V. Troubleshooting

Go to the [Troubleshooting](docs/troubleshooting.md) page.

## VI. Advanced topics

Go to the [Advanced topics](docs/advanced.md) page.

## Structure of this repo

Releases are defined as a Spack environment in the directory [`env/<release>/<variant>.yaml`](env/).

`repos/<name>/{repo.yaml,packages/}` constitute the FairSoft Spack package repositories. `<name>` can be:
* `fairsoft` which is the main FairSoft package repo, or
* `fairsoft-backports` which contains all the (potentially customized) upstream package overrides.

You may ignore the currently present `vae*` repository/ies which is for GSI/FAIR-internal use.

`config/` contains some general configuration changes needed on some systems. It's merged into the spack site config directory.

`spack/` is a git submodule which references the Spack git repo which currently contains both the Spack software and the Spack builtin package repository. Because some of the packages a FairSoft release pins down come from the Spack builtin repository, the idea is to pin it, too, to provide a reproducible build experience which does not depend on the various possible combination of Spack and FairSoft. The referenced submodule might also contain some extra patches, that we were not yet able to integrate into the upstream Spack itself.

`docs/` contains additional documentation pages, the relevant ones for the user should all be linked from this top-level page.

`legacy/` contains the former shell script based FairSoft before we switched to Spack, it is no longer updated, but remains for reference.

`test/` contains mainly integration test related files used by the FairSoft Continuous Integration checks. The normal user can ignore them.

CMake/CTest-related files are mainly for internal use and running the FairSoft Continuous Integration checks. The normal user can ignore them.

## Contributing

Please ask your questions, request features, and report issues by [creating a github issue](https://github.com/FairRootGroup/FairSoft/issues/new).
