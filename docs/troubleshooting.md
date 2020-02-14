# Troubleshooting

## Building DDS fails with external (non-spack) non-system compiler

**Error**

```
==> Executing phase: 'build'
==> Error: ProcessError: Command exited with status 2:
    'make' '-j8' 'wn_bin' 'all'

4 errors found in build log:
     318      possible problems:
     319        need more directories?
     320        need to use InstallRequiredSystemLibraries?
     321        run in install tree instead of build tree?
     322
     323    WN PKG prerequisite='libgcc_s.so.1'
  >> 324    CMake Error at /tmp/dklein/spack-stage/spack-stage-dds-3.0-ticzuzfxwnr3hclxxxkh3kwbyqq6svzi/spack-src/cmake/modul
            es/DDS_CollectPrerequisites.cmake:33 (file):
     325      file COPY cannot find
     326      "/tmp/dklein/spack-stage/spack-stage-dds-3.0-ticzuzfxwnr3hclxxxkh3kwbyqq6svzi/spack-build/libgcc_s.so.1":
     327      No such file or directory.
     328
     329
  >> 330    make[3]: *** [CMakeFiles/wn_bin.dir/build.make:64: CMakeFiles/wn_bin] Error 1
     331    make[3]: Leaving directory '/tmp/dklein/spack-stage/spack-stage-dds-3.0-ticzuzfxwnr3hclxxxkh3kwbyqq6svzi/spack-bu
            ild'
  >> 332    make[2]: *** [CMakeFiles/Makefile2:770: CMakeFiles/wn_bin.dir/all] Error 2
     333    make[2]: Leaving directory '/tmp/dklein/spack-stage/spack-stage-dds-3.0-ticzuzfxwnr3hclxxxkh3kwbyqq6svzi/spack-bu
            ild'
  >> 334    make[1]: *** [CMakeFiles/Makefile2:777: CMakeFiles/wn_bin.dir/rule] Error 2
     335    make[1]: Leaving directory '/tmp/dklein/spack-stage/spack-stage-dds-3.0-ticzuzfxwnr3hclxxxkh3kwbyqq6svzi/spack-bu
            ild'
     336    make: *** [Makefile:215: wn_bin] Error 2
```

**Solution**

```
$ spack compiler find
==> Added 1 new compiler to /home/dklein/.spack/linux/compilers.yaml
    gcc@8.3.0
==> Compilers are defined in the following files:
    /home/dklein/.spack/linux/compilers.yaml
```

Now whitelist the `$LD_LIBRARY_PATH` to be passed to the spack build environment:

```
$ spack python tools/dds_compiler_fix.py
*** Fixing compiler spec 'gcc@8.3.0' with prefix '/home/dklein/.spack/install_tree/linux-fedora31-skylake/gcc-9.2.1/gcc-8.3.0-xqpz6stvina7sfg3l7pm7lhscvtq57e6' to add LD_LIBRARY_PATH '/home/dklein/.spack/install_tree/linux-fedora31-skylake/gcc-9.2.1/gcc-8.3.0-xqpz6stvina7sfg3l7pm7lhscvtq57e6/lib'
```

Alternatively use the [yq command](https://github.com/mikefarah/yq), or you may also edit the file manually or by any other means:

```
$ yq w -i $HOME/.spack/linux/compilers.yaml 'compilers.(compiler.spec==gcc@8.3.0).compiler.environment.prepend-path.LD_LIBRARY_PATH' "$LD_LIBRARY_PATH"
compilers:
(...)
- compiler:
    spec: gcc@8.3.0
    paths:
      cc: /usr/lib64/ccache/gcc
      cxx: /usr/lib64/ccache/g++
      f77: /home/dklein/.spack/install_tree/linux-fedora31-skylake/gcc-9.2.1/gcc-8.3.0-xqpz6stvina7sfg3l7pm7lhscvtq57e6/bin/gfortran
      fc: /home/dklein/.spack/install_tree/linux-fedora31-skylake/gcc-9.2.1/gcc-8.3.0-xqpz6stvina7sfg3l7pm7lhscvtq57e6/bin/gfortran
    flags: {}
    operating_system: fedora31
    target: x86_64
    modules: []
    environment: {prepend-path: {LD_LIBRARY_PATH: '/home/dklein/.spack/install_tree/linux-fedora31-skylake/gcc-9.2.1/gcc-8.3.0-xqpz6stvina7sfg3l7pm7lhscvtq57e6/lib64:/home/dklein/.spack/install_tree/linux-fedora31-skylake/gcc-9.2.1/gcc-8.3.0-xqpz6stvina7sfg3l7pm7lhscvtq57e6/lib'}}
    extra_rpaths: []
(...)
```
