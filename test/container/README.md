## How to build and install legacy containers

```shell
cd build
cmake -DCMAKE_INSTALL_PREFIX=/cvmfs/fairsoft_dev.gsi.de/try-1 ..
cmake --build . --target all-legacy-containers
DESTDIR=/tmp/inst-1 cmake --install . --component container-legacy
```

Will install to
`/tmp/inst-1/cvmfs/fairsoft_dev.gsi.de/try-1/share/FairSoft/legacy`.

You can use `-DFairSoft_CONTAINER_DIR` to customize the
`share/FairSoft` part.
