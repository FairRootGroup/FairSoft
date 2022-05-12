## How to build and install all containers

```shell
cd build
cmake -DCMAKE_INSTALL_PREFIX=/cvmfs/fairsoft_dev.gsi.de/ci/for-fairsoft/latest \
    -DFairSoft_CONTAINER_DIR=container ..
cmake --build . --target all-containers
DESTDIR=/tmp/inst-1 cmake --install . --component containers
```

Will install to
`/tmp/inst-1/cvmfs/fairsoft_dev.gsi.de/ci/for-fairsoft/latest/container`.
