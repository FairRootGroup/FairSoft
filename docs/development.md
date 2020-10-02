## IV. Development

### IV.1. Classic "cmake -> make -> make install" workflow (FairRoot and/or Experiment)

```
[jun19] $ export SIMPATH=<path of your choice>
[jun19] $ spack view --dependencies true [-e fairroot] symlink -i $SIMPATH fairroot [cmake]
```

The above will create a directory structure at the path of your choice that can be used as
* $SIMPATH - with `-e fairroot`, or
* $SIMPATH and $FAIRROOTPATH - without `-e fairroot`.

If you need a newer CMake version than your system provides, add `cmake` at the end of the `spack view` command which will make a recent version available at `$SIMPATH/bin/cmake`.

A $SIMPATH created as shown above may be removed by a simple `rm -rf $SIMPATH`. This will **not** uninstall the packages themselves and you may recreate the view without recompilation.

### IV.2. Spack dev-build (single-package)

A package can be built in development mode - without checking it out from repository. In this case the code will be taken from local directory SOURCE_PATH.
Following command will run development build of FairRoot with dependencies equivalent to jun19 environemnt on macOS. Currently this has to be configured manually.

```
spack dev-build -j JOBS -d SOURCE_PATH fairroot@18.2.1+sim+examples ^pcre+jit ^python@2.7.16 ^py-numpy@1.16.5 ^googletest@1.8.1 ^boost@1.68.0 ^fairlogger@1.4.0 \
^dds@2.4 ^fairmq@1.4.3 ^pythia6@428-alice1 ^hepmc@2.06.09 length=CM momentum=GEV ^pythia8@8240 ^geant4@10.05.p01~qt~vecgeom~opengl~x11~motif~data~clhep~threads \
^root@6.16.00+fortran+gdml+memstat+pythia6+pythia8+vc~vdt+python+tmva+xrootd+aqua ^geant3@2-7_fairsoft ^vgm@4-5 ^geant4-vmc@4-0-p1
```
