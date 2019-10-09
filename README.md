# FairSoft
This holds a set of Spack packages for FAIR software.  It depends
on Spack and the builtin Spack packages (some of which are overridden
by this repo)

```
git clone https://github.com/kresan/FairSoft.git
cd FairSoft
git checkout cmake_build
mkdir build install
cd build
cmake -DCMAKE_INSTALL_PREFIX=../install
make
make install
```

Please read the full documentation at [docs/README.md](docs/README.md)
