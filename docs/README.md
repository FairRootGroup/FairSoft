# FairSoft-Spack
This holds a set of Spack packages for FAIR software.  It depends
on Spack and the builtin Spack packages (some of which are overridden
by this repo)

## Getting started

Initial setup like:

```bash
cd (Choose-dir)
git clone https://github.com/spack/spack
cd spack
git checkout may18
cd (Choose-dir)
git clone https://github.com/FairRootGroup/FairSoft-Spack
git checkout may18
cd (Choose-dir)
```

## Setup your Spack environment

Next add Spack to your path. Spack has some nice command line integration tools,
so instead of simply appending to your PATH variable, source the spack setup script.
This also adds Spack to your path.

```bash
cd (Choose-dir)
source spack/share/spack/setup-env.sh
```


Depending on your use case, you may want to provide configuration settings common to everyone on your team,
or you may want to set default behaviors specific to a single user account.
Spack provides six configuration scopes to handle this customization.
These scopes, in order of decreasing priority, are:


| Scope        | Directory |
| ------------ | --------- |
| Command-line | N/A       |
| Custom       | Custom directory, specified with --config-scope |
| User         | ~/.spack/ |
| Site         | $SPACK_ROOT/etc/spack/ |
| System       | /etc/spack/ |
| Defaults     | $SPACK_ROOT/etc/spack/defaults/ |


Spack allows customization of several high-level settings.
These settings are stored in the generic config.yaml configuration file.
You can see the default settings by running:

```bash
spack config --scope defaults edit config
```

which opens the file $SPACK_ROOT/etc/spack/defaults/config.yaml. Either change the default settings
or copy the file

```bash
cp $SPACK_ROOT/etc/spack/defaults/config.yaml ~/.spack/
```

to your user scope.

The default configuration defines the installtion directory to be
$SPACK_ROOT/opt/spack. Since this will do the installation into the local working copy
we recommend to change the installation directory.

A full description of all the various configuration options can be found
in the [Spack documentation.](https://spack.readthedocs.io/en/latest/tutorial_configuration.html)

## Use system packages

Sometimes it could also be necessary that Spack uses externally installed packages.
For example this is a solution if a package can't be build on a system.
Package preferences in Spack are managed through the packages.yaml configuration file.
First, we will look at the default packages.yaml file.

```bash
spack config --scope defaults edit packages
```

Either change the default settings or copy the file

```bash
cp $SPACK_ROOT/etc/spack/defaults/package.yaml ~/.spack/
```

to your user scope. A full description of all the package options can be found
in the [Spack documentation.](https://spack.readthedocs.io/en/latest/tutorial_configuration.html#external-packages)

This settings in the file define the default preferences for compilers and
for providers of virtual packages. There are no externally installed packages
defined yet. To define these you need a description like the following to the file


```bash
zlib:
    paths:
      zlib@1.2.8%gcc@5.4.0 arch=linux-ubuntu16.04-x86_64: /usr
```

Here zlib is the name of the package which should be taken from the system.
zlib@1.2.8%gcc@5.4.0 is the complete description of the package to be used from an
external location, which is version 1.2.8 of zlib compiled with gcc at version 5.4.0.
arch=linux-ubuntu16.04-x86_64: describes the system for which this package should be used
which is a 64bit version Ubuntu Linux 16.04. And finally it is described wehere the
installed package is found, in this case it is /usr.

### Use needed system package on macosx 10.12

We encountered compilation problems on macosx 10.12. At least on this system it was impossible to
compile the mesa package which provides the OpenGL support. The problem with python was that
packages which depends on python showed compilation errors which were related to the python
installation. The compilation of python itself worked without problems.

To solve theses issues we add the following lines:

```bash
  mesa:
    paths:
      mesa~llvm@19.0.4%clang@9.0.0-apple arch=darwin-sierra-x86_64: /usr/local/Cellar/mesa/19.0.2
  python:
    paths:
      python+shared@3.7.3%clang@9.0.0-apple arch=darwin-sierra-x86_64: /usr/local/Cellar/python/3.7.3
```

## Use existing Spack installation

You can point your Spack installation to another installation to use any packages that are installed there.
A single Spack instance can use multiple upstream Spack installations. Spack will search upstream instances
in the order you list them in your configuration. If your installation refers to instances X and Y,
in that order, then instance X must list Y as an upstream in its own upstreams.yaml.

To register any other Spack instance, you can add it as an entry to upstreams.yaml file.
If the file does not exist yet you have to create it in ~/.spack:

```bash
upstreams:
  spack-instance-1:
    install_tree: /path/to/other/spack/opt/spack
  spack-instance-2:
    install_tree: /path/to/another/spack/opt/spack
```

Once the upstream Spack instance has been added, spack will automatically check the upstream instance when
querying installed packages, and new package installations for the local Spack install will use any
dependencies that are installed in the upstream instance.

A full description of all the upstream options can be found
in the [Spack documentation.](https://spack.readthedocs.io/en/latest/chain.html)


### Use GSI installation on CVMFS

At GSI there is already a central Spack installation of FairRoot on CVMFS. To use this installation
add the following lines to your upstreams.yaml file:

```bash
upstreams:
  spack-instance-1:
    install_tree: /cvmfs/fairroot.gsi.de/spack
```

## Install a package using Spack

After all the previous steps Spack should be used to install FairRoot. This is in the end done rather simple
using the following command:

```bash
spack install fairroot
```

Since the dependency tree of FairRoot is rather large this step can take quite some time. If you are using an
existing external Spack installation with all needed packages already installed the step only takes some seconds.
In any case the result should b 


## Setup the correct runtime environment

