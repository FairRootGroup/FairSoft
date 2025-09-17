# Advanced topics

Table of Contents
* [Inspecting the build logs](#inspecting-the-build-logs)
* [Offline installation](#offline-installation)
* [`$DESTDIR` Not Supported](#destdir-not-supported)
* [macOS SDK](#macos-sdk)

## Inspecting the build logs

Build logs are written to the `<path-to-build>/Log` directory.

## Offline installation

By default sources and data files are downloaded from various servers during
the installation of FairSoft. One may pre-download all those files and perform
an offline installation by passing the `-DSOURCE_CACHE` argument to the
CMake configure step.

```
cmake -S <path-to-source> -B <path-to-build> -DCMAKE_INSTALL_PREFIX=<path-to-install> -DSOURCE_CACHE=<source-cache-tarball>
```

You can create a source cache tarball by running

```
cmake --build <path-to-build> --target source-cache [-j<ncpus>]
```

## `$DESTDIR` Not Supported

As FairSoft legacy is a multi package super build,
`$DESTDIR` is not supported.  Later packages in the build
process might either not find the staging area, or bake the
DESTDIR value into resulting artifacts.

## macOS SDK

On macOS, system headers are provided via macOS SDKs (Software Development
Kit). macOS SDKs are distributed with XCode and the "Command Line Tools for
XCode" (short CLT, which is a stripped down version of the XCode toolchain
focussed on command line usage). So, in practice, a macOS with CLT and/or
XCode installations contains effectively multiple copies of system headers
and libraries in different versions. See the manpages `xcrun(1)` and
`xcode-select(1)` for all the details on how to configure macOS on which
SDK and toolchain to use.

We found that - in some cases - the selection of the SDK differs between
`brew`, `cmake` and default shell environment (likely depending on the system's
upgrade history, user configuration, and software versions). For most
software packages this is not an issue. However, the ROOT is very sensitive on
the chosen SDK. This is a known issue to the upstream ROOT developers, but so
far they have not found a way to make this more robust (as of a comment by Axel
in April '22). A "wrong" SDK may result in compilation errors as reported in
https://github.com/root-project/root/issues/7881.

While this is not completely understood, we believe picking the latest
installed SDK version is the most sensible course of action here. `brew`
contains already some logic to detect and choose the latest SDK. See the
"macOS SDK" section in [FairSoftConfig.cmake](../FairSoftConfig.cmake).

The downside with picking the latest SDK version is that some older ROOT
versions can't be compiled any longer after updating the compiler and the
connected SDK. As described above the problems with compilation errors due
to **wrong** SDKs are because of ROOT and there mainly becuase of rootcling.
To overcome the problem and allow a more flexible compilation also with
non default SDKs we add the possibilty to define an older SDK when running
CMake. There are some additional changes in the build system of ROOT such
that rootcling take the setting properly into account. With this changes it
becomes possible to install FairSoft jan24 (ROOT 6.30.08) with Apple Clang
17 on macosx 15.

**If you have a deeper understanding of this issue and know a better
solution, please let us know!**

*Note*: Setting the `$SDKROOT` environment variable (or alternatively the
[`-DCMAKE_OSX_SYSROOT`](https://cmake.org/cmake/help/latest/variable/CMAKE_OSX_SYSROOT.html)
variable) may also be needed when compiling **FairRoot** and your
**ExperimentRoot**, e.g.

```bash
export SDKROOT=$(brew ruby -e "puts MacOS.sdk_path")
```
