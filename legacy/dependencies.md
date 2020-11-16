# System dependencies

Pick the appropriate setup script for your system and run it. On Linux systems
you may need to run the script with `sudo`.

* [`legacy/setup-centos-7.sh`](setup-centos-7.sh)
* [`legacy/setup-debian.sh`](setup-debian.sh)
* [`legacy/setup-fedora.sh`](setup-fedora.sh)
* [`legacy/setup-macos.sh`](setup-macos.sh)
* [`legacy/setup-opensuse.sh`](setup-opensuse.sh)
* [`legacy/setup-ubuntu.sh`](setup-ubuntu.sh)

**Please read the scripts carefully and make sure you agree with the changes to your system!!**

These scripts are maintained on a best-effort basis. If you find something missing or not working,
please describe your case by [opening an issue](https://github.com/FairRootGroup/FairSoft/issues/new)
and let us discuss a solution together.

## Bootstrapping CMake

If your system does not provide the required CMake version (`3.16.1`), you may
run

```
<path-to-source>/bootstrap-cmake.sh <install-dir>
export PATH=<install-dir>/bin:$PATH
```

to install a recent CMake version to an `<install-dir>` of your choice.
`<path-to-source>` is the path to your FairSoft git clone.
