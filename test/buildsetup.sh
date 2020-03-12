#! /bin/bash

if [ -z "$LABEL" ]
then
	if which lsb_release >/dev/null
	then
		export LABEL="$(lsb_release -s -i)-$(lsb_release -s -r)"
	fi
fi

echo "*** LABEL: $LABEL"
echo -n "*** Host : "
hostname -f

# echo "==> Environment:"
# env | sed -e 's/^/==>  | /'

# echo -n "*** Number of threads per python: "
# python3 -c 'import multiprocessing; print(multiprocessing.cpu_count())'

if [ ! -d "$TARGETDIR" ]
then
	TARGETDIR="$(mktemp -d)"
	echo "*** Created test directory: $TARGETDIR"
else
	echo "*** Reusing test directory: $TARGETDIR"
fi

export HOME="$TARGETDIR"

if [ ! -d "$HOME/.spack/" ]
then
	echo "*** Setting up spack"
	mkdir -p "$HOME/.spack/"
	cat >"$HOME/.spack/config.yaml" <<EOF
config:
  install_tree: '$HOME/install-tree'
  module_roots:
    tcl: '$HOME/install-tree/modules'
  source_cache: '$HOME/source-cache'
  build_stage:
  - '$HOME/stage'
EOF

	if [ -n "$SLURM_CPUS_PER_TASK" ]
	then
		echo "  build_jobs: $SLURM_CPUS_PER_TASK" >>"$HOME/.spack/config.yaml"
	fi

	cat "$HOME/.spack/config.yaml"
	mkdir -v -p "$HOME/install-tree"
	mkdir -v -p "$HOME/stage"

	. spack/share/spack/setup-env.sh

	if (hostname --all-fqdns 2>/dev/null || hostname -f) | grep '[.]gsi[.]de *$' >/dev/null
	then
		spack mirror add test http://citpc008.gsi.de/spack/source-cache
	fi

	spack repo add .
else
	. spack/share/spack/setup-env.sh
fi

echo "*** [$(date +%H:%M:%S)] Starting"
