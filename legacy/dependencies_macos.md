__Build Prerequisites on Mac OS X__

The easiest way to come to a running environment on Mac OSX is to follow the instructions given here. For all of the following command you need a Terminal. If you don't know where to find it, you can use Spotlight. Simply type "Terminal" in the Spotlight search window and click on the Terminal application. This will open the Terminal application.


 * Install Xcode from App Store
 * Get the system compiler and most of the development tools by installing Apple's command line tools.  Please type in the Terminal session the following command.
  * sudo xcode-select --install

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

``` ln -s /usr/local/opt/openssl/include/openssl /usr/include ```

El Capitan OS includes a System Integrity protection that prevents users to write in the /usr folder. If you have problems with this feature to install the packages, disable it rebooting the computer pressind CMD+R and open a terminal to type:

```
csrutil disable
```


If your need to switch this of in a virtual machine please follow the instructions at http://anadoxin.org/blog/disabling-system-integrity-protection-from-guest-el-capitan-under-virtualbox-5.html


Then, reboot computer.

When you successfully reached this point you have all needed prerequisites to be able to install FairSoft.
