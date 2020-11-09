# System dependencies

Pick the appropriate setup script for your system and run it. On Linux systems
you may need to run the script with `sudo`.

* [`legacy/setup-fedora.sh`](setup-fedora.sh)
* [`legacy/setup-macos.sh`](setup-macos.sh)
* [`legacy/setup-ubuntu.sh`](setup-ubuntu.sh)

## Bootstrapping CMake

If your system does not provide the required CMake version (`3.16.1`), you may
run

```
<path-to-source>/bootstrap-cmake.sh <install-dir>
export PATH=<install-dir>/bin:$PATH
```

to install a recent CMake version to an `<install-dir>` of your choice.
`<path-to-source>` is the path to your FairSoft git clone.
