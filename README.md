# FairSoft

The FairSoft distribution provides the software packages needed to compile and run the [FairRoot framework](https://github.com/FairRootGroup/FairRoot) and experiment packages based on FairRoot. FairSoft is a source distribution with recurring releases for macOS and Linux.

## Spack based (EXPERIMENTAL) or [Legacy](legacy/README.md) installation

This release features both, a classic (called "Legacy") installation method, and a new spack based one.

* **Spack based**: This is to be considered EXPERIMENTAL. It is still being developed. Most things are already working, but there are a bunch of issues. Spack itself is also still in heavy development. If you're interested in this new system, read on in the next section.

* **Legacy**: This is the known, and proven shell based setup system. Please continue [here](legacy/README.md).

## Spack based setup (EXPERIMENTAL)

This release of FairSoft will be the last featuring the classic
(or "Legacy") FairSoft installation method. 


The newly released FairSoft modernizes and reorganizes the framework installation.
All needed packages, including the FairRoot package itself,
are now installed using [Spack](https://spack.readthedocs.io/en/latest/).

The packages are installed by Spack automatically using package [recipes](https://spack-tutorial.readthedocs.io/en/latest/tutorial_packaging.html), stored in the corresponding folders of the [packages](./repos/fairsoft/packages) directory. The [recipe](https://spack-tutorial.readthedocs.io/en/latest/tutorial_packaging.html)
lists the dependencies of the given package and describes its installation procedure. A collection of packages that form the software framework is called [spack environment](https://spack.readthedocs.io/en/latest/environments.html)  - examples of such are located in the [env](./env) directories.

In the process of installing of a package, Spack creates its list of dependencies,
forming the so-called installation tree. It is possible to install different packages/versions with [Spack](https://spack.readthedocs.io/en/latest/). Since they share a common installation tree, the Spack reuses already available software when installing new package.


### Table of Contents
* [I. Preparation](docs/preparation.md) (download the package)
* [II. Installation](docs/installation.md) (install packages in environment)
* [III. Execution](docs/execution.md) (using the framework)
* [IV. Development](docs/development.md)
* [V. Troubleshooting](docs/troubleshooting.md)
* [VI. Advanced topics](docs/advanced.md)

Appendix:
* [Structure of this repo](docs/structure.md)
---

## Contributing

Please ask your questions, request features, and report issues by [creating a github issue](https://github.com/FairRootGroup/FairSoft/issues/new).
