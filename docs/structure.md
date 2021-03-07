## Structure of this repo

Releases are defined as a Spack environment in the directory [`env/<release>/<variant>.yaml`](env/).

`repos/<name>/{repo.yaml,packages/}` constitute the FairSoft Spack package repositories. `<name>` can be:
* `fairsoft` which is the main FairSoft package repo, or
* `fairsoft-backports` which contains all the (potentially customized) upstream package overrides.

You may ignore the currently present `vae*` repository/ies which is for GSI/FAIR-internal use.

`config/` contains some general configuration changes needed on some systems. It's merged into the spack site config directory.

`spack/` is a git submodule which references the Spack git repo which currently contains both the Spack software and the Spack builtin package repository. Because some of the packages a FairSoft release pins down come from the Spack builtin repository, the idea is to pin it, too, to provide a reproducible build experience which does not depend on the various possible combination of Spack and FairSoft. The referenced submodule might also contain some extra patches, that we were not yet able to integrate into the upstream Spack itself.

`docs/` contains additional documentation pages, the relevant ones for the user should all be linked from this top-level page.

`legacy/` contains the former shell script based FairSoft before we switched to Spack, it is no longer updated, but remains for reference.

`test/` contains mainly integration test related files used by the FairSoft Continuous Integration checks. The normal user can ignore them.

CMake/CTest-related files are mainly for internal use and running the FairSoft Continuous Integration checks. The normal user can ignore them.

`pacthes/` contains package-level patches used in package repos that forbid embedded packages by policy.
