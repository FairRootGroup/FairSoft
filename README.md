# FairSoft-Spack
This holds a set of Spack packages for FAIR software.  It depends
on Spack and the builtin Spack packages (some of which are overridden
by this repo)

## Getting started

Initial setup like:

```bash
cd /mydir
git clone https://github.com/LLNL/spack.git
cd spack/var/spack/repos
git clone https://github.com/FairRootGroup/FairSoft-Spack.git
cd -
./spack/bin/spack repo add spack/var/spack/repos/FairSoft-Spack
```
