# FairSoft

The FairSoft distribution provides the software packages needed to compile and run the [FairRoot framework](https://github.com/FairRootGroup/FairRoot) and experiment packages based on FairRoot. FairSoft is a source distribution with recurring releases for macOS and Linux.

## Installation from Source

Choose between the classic (called "Legacy") installation method or the new Spack-based one:

| **Legacy (Recommended)** | **Spack (EXPERIMENTAL)** |
| -- | -- |
| This is the classic bash/cmake based setup system. | This is an ongoing standardization and modernization effort based on Spack (which itself is still under heavy development). Most things are already working. For early adopters. |
| Releases are reflected in the git history via tags and branches, e.g.: `jan24`, `nov22`, `apr21p2`, `apr21_patches` | Always use the latest `dev` branch. Multiple releases are described within the metadata contained in the repo (read on in the Installation instructions on how to select a release). |
| ► [continue](legacy/README.md) | ► [continue](docs/README.md) |

## Installation of pre-compiled Binaries

*Note*: FairSoft is primarily a source distribution. Availability of latest releases as pre-compiled binaries may be delayed.

### GSI Virgo Cluster

For all [VAEs](https://hpc.gsi.de/virgo/platform/software.html#application-environment) at `/cvmfs/fairsoft.gsi.de/<vae-os>/fairsoft/<release>`. Use by exporting the `SIMPATH` environment variable pointing to one of the directories.

### macOS (beta)

Tested: `macOS 12 (x86_64)`, `macOS 13 (x86_64)`, `macOS 13 (arm64)` with *Command Line Tools for Xcode* `14`

FairSoft config: [default](FairSoftConfig.cmake), no other configs planned

1. Install *Command Line Tools for Xcode* from https://developer.apple.com/downloads (requires Apple account)
2. Install [Homebrew](https://brew.sh/)
3. Run `brew update && brew doctor` and fix potential issues reported by these commands until `Your system is ready to brew.`
4. Run
```
brew tap fairrootgroup/fairsoft
brew install fairsoft@22.11
```
5. Use via `export SIMPATH=$(brew --prefix fairsoft@24.1)`

*Note*: macOS is a fast moving target and it is possible the packages will stop working from one day to another after some system component was updated. We try our best to keep up, one great way to help is to provide detailed problem reports [here on github](https://github.com/FairRootGroup/FairSoft/issues/new).

### Other platforms

Binary packages for non-GSI Linux as well as Spack binary caches and/or pre-populated install trees are planned for the future.

## Contributing

Please ask your questions, request features, and report issues by [creating a github issue](https://github.com/FairRootGroup/FairSoft/issues/new).
