#!/bin/bash

fairsoft_basedir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fairsoft_spackdir=${fairsoft_basedir}/spack
fairsoft_configdir=${fairsoft_basedir}/config

spack_log() {
  spack python -c "import llnl.util.tty as tty; tty.$1('$2')"
}

register_spack_extension() {
  ext="$(realpath -e ${fairsoft_basedir}/extensions/spack-$1)"
  if [ -d "$ext" ]
  then
    if spack python -c "from spack.config import get; exts = get('config:extensions') or []; exit(0) if '$ext' not in exts else exit(1)"
    then
      spack_log info "Registering extension ${ext}"
      spack config --scope site add "config:extensions:${ext}"
    fi
  fi
}

. "${fairsoft_spackdir}/share/spack/setup-env.sh"

if [ "$1" = "--setup" ]
then
  register_spack_extension "fairsoft"
  spack fairsoft setup --config-dir ${fairsoft_configdir}
fi

unset -f spack_log
unset -f register_spack_extension
unset fairsoft_basedir
unset fairsoft_spackdir
unset fairsoft_configdir
