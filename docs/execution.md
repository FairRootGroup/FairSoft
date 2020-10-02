## III. Execution

### III.1. Spack view

Symbolic links to packages in install tree can be placed to a common installation prefix using view command.
This will create a directory, which can be used as SIMPATH and FAIRROOTPATH in order to build experiment-specific frameworks.
View is created by following command:

Linux
```
[jun19] $ spack view --dependencies true symlink -i (YOUR_SIMPATH) fairroot
```

macOS
```
[jun19] $ spack view --dependencies true -e libpng -e libjpeg-turbo -e libiconv -e sqlite symlink -i (YOUR_SIMPATH) fairroot
```

The view creation has to be done within an [activated environment](#iii2-activate-the-spack-environment).

### III.2. Spack load (beta)

As an alternative to the view the Spack offers the [module mechanism](https://spack.readthedocs.io/en/latest/module_file_support.html), allowing the user to set the running environment using the load command:

```
[jun19] $ spack load --dependencies fairroot
```

This will set the corrects paths to run the environment.

__This functionally is not yet fully supported.__
