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

to your user scope. The default configuration defines the installtion directory to be 
$SPACK_ROOT/opt/spack. Since this will do the installation into the local working copy
we recommend to change the installation directory.

## Use system packages 

## Use GSI installation on CVMFS
