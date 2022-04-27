# Advanced topics

Table of Contents
* [Inspecting the build logs](#inspecting-the-build-logs)
* [Offline installation](#offline-installation)
* [`$DESTDIR` Not Supported](#destdir-not-supported)

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
