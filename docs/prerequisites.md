# FairSoft Prerequisites

In the following sections you can find instructions to install software assumed to be available on your Linux or macOS system prior to installing FairSoft.

## Linux

Find the distro-specific setup in the `%post` section in the following [singularity](https://sylabs.io/docs/) container definition files:

* **Fedora**: [33](../test/container/fedora.33.def)
* **CentOS**: [7](../test/container/centos.7.def)
* **Debian**: [10](../test/container/debian.10.def)
* **Ubuntu**: [20.04](../test/container/ubuntu.20.04.def)
* **openSUSE**: [15.2](../test/container/opensuse.15.2.def)

## macOS

* Install the latest Xcode CLT (Command Line Tools) from developer.apple.com (requires Apple ID)

* Install the latest [Homebrew](https://brew.sh/)

```bash
brew update
brew doctor  # Address any issues reported here until your system is ready to brew
brew install gcc python
```
