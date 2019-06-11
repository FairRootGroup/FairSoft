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
For example this is a solution if a package can't be build on a system. We encountered the
problem on macosx 10.12 where we had to use two packages from the system.

Package preferences in Spack are managed through the packages.yaml configuration file.
First, we will look at the default packages.yaml file.

```bash
spack config --scope defaults edit packages
```

Either change the default settings or copy the file

```bash
cp $SPACK_ROOT/etc/spack/defaults/package.yaml ~/.spack/
```

to your user scope.

This settings in the file define the default preferences for compilers and
for providers of virtual packages. There are no externally installed packages
defined yet. To define these you need a description like the following to the file


```bash
zlib:
    paths:
      zlib@1.2.8%gcc@5.4.0 arch=linux-ubuntu16.04-x86_64: /usr
```

Here zlib is the name of the package which should be taken from the system.
zlib@1.2.8%gcc@5.4.0 is the complete description of the package to be installed
which is version 1.2.8 of zlib compiled with gcc at version 5.4.0.
arch=linux-ubuntu16.04-x86_64: describes the system for which this package should be used
which is a 64bit version Ubuntu Linux 16.04. And finally it is described wehere the
installed package is found.

To solve the issue with mac osx 10.12 the following lines have to be added.

```bash
  mesa:
    paths:
      mesa~llvm@19.0.4%clang@9.0.0-apple arch=darwin-sierra-x86_64: /usr/local/Cellar/mesa/19.0.2
  python:
    paths:
      python+shared@3.7.3%clang@9.0.0-apple arch=darwin-sierra-x86_64: /usr/local/Cellar/python/3.7.3
```

## Use GSI installation on CVMFS
