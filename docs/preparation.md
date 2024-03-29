## I. Preparation

### I.1. Install the [prerequisites](prerequisites.md).

### I.2. Clone the repo

If you are running on NFS, please take note the [Filesystem requirements](https://spack.readthedocs.io/en/latest/basic_usage.html#filesystem-requirements) of spack on the ``flock`` requirements of spack and possible workarounds. Also, compiling ROOT with X11 support will install font-related packages which require ``$HOME/.cache/fontconfig/`` to support locking.

```
git clone -b dev https://github.com/FairRootGroup/FairSoft
cd FairSoft
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
