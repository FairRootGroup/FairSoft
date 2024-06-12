# System dependencies

Pick the appropriate [`legacy/setup-*.sh`](/legacy/) for your system and run it.
On Linux systems you may need to run the script with `sudo`.

**Please read the scripts carefully and make sure you agree with the changes to
your system!!**

These scripts are maintained on a best-effort basis. If you find something
missing or not working, please describe your case by
[opening an issue](https://github.com/FairRootGroup/FairSoft/issues/new) and
let us discuss a solution together.

## Bootstrapping CMake

If your system does not provide the required CMake version, you may run

```
<path-to-source>/bootstrap-cmake.sh <install-dir>
export PATH=<install-dir>/bin:$PATH
```

to install a recent CMake version to an `<install-dir>` of your choice.
`<path-to-source>` is the path to your FairSoft git clone.
