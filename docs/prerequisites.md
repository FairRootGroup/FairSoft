# FairSoft Prerequisites

In the following sections you can find instructions to install software assumed to be available on your Linux or macOS system prior to installing FairSoft.

## Linux

Find the distro-specific setup in the `%post` section in the following [singularity](https://sylabs.io/docs/) container definition files:

* **Fedora**: [30](../test/container/fedora.30.def)
* **CentOS**: [7](../test/container/centos.7.def)
* **Debian**: [10](../test/container/debian.10.def)
* **Ubuntu**: [18.04](../test/container/ubuntu.18.04.def)
* **openSUSE**: [15.1](../test/container/opensuse.15.1.def)


Redhat, CentOS, Scientific Linux and other Redhat based systems
```
yum install cmake gcc gcc-c++ gcc-gfortran make patch sed \
  libX11-devel libXft-devel libXpm-devel libXext-devel \
  libXmu-devel mesa-libGLU-devel mesa-libGL-devel ncurses-devel \
  curl curl-devel bzip2 bzip2-devel gzip unzip tar \
  expat-devel subversion git flex bison imake redhat-lsb-core python-devel \
  libxml2-devel wget openssl-devel krb5-devel \
  automake autoconf libtool which
```

Suse, OpenSuse and other Suse based systems
```
zypper install cmake gcc gcc-c++ gcc-fortran make patch sed \
  libX11-devel libXft-devel libXpm-devel libXext-devel \
  libXmu-devel Mesa-libGL-devel freeglut-devel ncurses-devel \
  curl libcurl-devel bzip2 libbz2-devel gzip unzip tar \
  libexpat-devel subversion git flex bison makedepend lsb-release python-devel \
  libxml2-devel libopenssl-devel krb5-devel wget \
  libcurl-devel automake autoconf libtool which
```

## macOS

The easiest way to come to a running environment on Mac OSX is to follow the instructions given here. For all of the following command you need a Terminal. If you don't know where to find it, you can use Spotlight. Simply type "Terminal" in the Spotlight search window and click on the Terminal application. This will open the Terminal application.

 * Install Xcode from App Store
 * Get the system compiler and most of the development tools by installing Apple's command line tools.  Please type in the Terminal session the following command.
  * `sudo xcode-select --install`

Depending on the version of Apple OS X system, one needs additional packages defined below.

**Mac OS X 10.8 and earlier**

* X11User (for the X11 server)
* [gfortran](http://hpc.sourceforge.net)

**Mac OS X 10.9 (Mavericks) and 10.10 (Yosemite)**
* [XQuartz](http://xquartz.macosforge.org/landing/) version 2.7.5 and later
* [gfortran](http://hpc.sourceforge.net)  version 4.9 only


**Mac OS X 10.11 (El Capitan) and newer**

In El Capitan other packages are needed. The easiest way is to install them with brew:

```
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```
Then:

```
brew install Caskroom/cask/xquartz
```
```
brew install gcc cmake autoconf automake libtool openssl pkg-config
```

Then:

__EITHER__

```
 export OPENSSL_ROOT_DIR=`brew --prefix openssl`
 export OPENSSL_INCLUDE_DIR=$OPENSSL_ROOT_DIR/include/openssl
```
__OR__

```
ln -s /usr/local/opt/openssl/include/openssl /usr/include
```

El Capitan OS includes a System Integrity protection that prevents users to write in the /usr folder. If you have problems with this feature to install the packages, disable it rebooting the computer pressind CMD+R and open a terminal to type:

```
csrutil disable
```

If your need to switch this of in a virtual machine please follow the instructions at http://anadoxin.org/blog/disabling-system-integrity-protection-from-guest-el-capitan-under-virtualbox-5.html

Then, reboot computer.
