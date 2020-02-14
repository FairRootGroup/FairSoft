#! /usr/bin/python3

import sys
import os
import os.path
from spack.util.spack_yaml import load, dump

if sys.platform != "linux":
    print("This script supports only Linux")
    sys.exit(1)

fn = os.environ["HOME"] + "/.spack/linux/compilers.yaml"

with open(fn, "rb") as f:
   data = load(f)

compilers = data['compilers']

for comp in compilers:
    comp = comp['compiler']
    paths = comp['paths']
    prefixes = []
    for bin, binpath in paths.items():
        binpath = os.path.dirname(binpath)
        if os.path.basename(binpath) == 'bin':
            binpath = os.path.dirname(binpath)
            prefixes.append(binpath)
    prefix = os.path.commonprefix(prefixes)
    if prefix.startswith("/usr") or prefix == "/":
        continue
    ld_paths = os.environ.get("LD_LIBRARY_PATH", "")
    ld_paths = ld_paths.split(os.path.pathsep)
    found_ld_paths = []
    for ld_elm in ld_paths:
        if ld_elm.startswith(prefix) and os.path.isdir(ld_elm):
            found_ld_paths.append(ld_elm)
    if len(found_ld_paths) == 0:
        continue
    found_ld_paths = os.path.pathsep.join(found_ld_paths)
    elm = comp.setdefault('environment', {})
    elm = elm.setdefault('prepend-path', {})
    elm["LD_LIBRARY_PATH"] = found_ld_paths
    print("*** Fixing compiler spec %r with prefix %r to add LD_LIBRARY_PATH %r" % (comp['spec'], prefix, found_ld_paths))

with open(fn, "w") as f:
    dump(data, stream=f)
