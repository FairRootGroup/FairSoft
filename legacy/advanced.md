# Advanced topics

Table of Contents
* [Inspecting the build logs](#inspecting-the-build-logs)
* [Offline installation](#offline-installation)
* [Rebuilding a package](#rebuilding-a-package)

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

## Rebuilding a package

As long as you keep the build directory around, it is possible to make changes
to the sources of a package and rebuild it.

* `<path-to-build>/Sources/<package>` contains the packages sources
* `<path-to-build>/Build/<packages>` contains the build directories of packages
with out-of-source builds

After modifying the source, run

```
cmake --build <path-to-build> --target <package> [-j<ncpus>]
```

to *incrementally* rebuild the given `<package>` and its dependencies.

Note: Files installed to `<path-to-install>` from previous builds are **not** removed
on rebuilds.
