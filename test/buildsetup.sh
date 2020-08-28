#! /bin/bash

export SIMPATH="$PWD/test/simpath_broken"
export FAIRSOFT_ROOT="$SIMPATH"

if [ -z "$LABEL" ]
then
	if which lsb_release >/dev/null
	then
		export LABEL="$(lsb_release -s -i)-$(lsb_release -s -r)"
	fi
fi

if [ -n "$BUILD_URL" ]
then
	echo "*** BUILD Url ............: $BUILD_URL"
fi
if [ -n "$RUN_CHANGES_DISPLAY_URL" ]
then
	echo "*** Changes in this run ..: $RUN_CHANGES_DISPLAY_URL"
fi

echo "*** LABEL ................: $LABEL"
echo -n "*** Host .................: "
hostname -f

if command -v lsb_release >/dev/null 2>&1
then
	echo "*** lsb_release output ...: $(lsb_release -sd)"
fi
if command -v sw_vers >/dev/null 2>&1
then
	echo "*** sw_vers output .......: $(sw_vers -productName) $(sw_vers -productVersion) $(sw_vers -buildVersion)"
fi

# echo "==> Environment:"
# env | sed -e 's/^/==>  | /'

# echo -n "*** Number of threads per python: "
# python3 -c 'import multiprocessing; print(multiprocessing.cpu_count())'

if [ ! -d "$FS_TEST_WORKDIR" ]
then
	FS_TEST_WORKDIR="$(mktemp -d)"
	echo "*** Created test directory: $FS_TEST_WORKDIR"
else
	echo "*** Reusing test directory: $FS_TEST_WORKDIR"
fi

if [ "$SPACK_CCACHE" = "true" ]
then
  CCACHE_CACHEDIR="$(ccache -k cache_dir)"
  CCACHE_MAXSIZE="$(ccache -k max_size)"
fi

export HOME="$FS_TEST_WORKDIR"

if [ ! -d "$HOME/.spack/" ]
then
	echo "*** Setting up spack"
	mkdir -p "$HOME/.spack/"
	cat >"$HOME/.spack/config.yaml" <<EOF
config:
  db_lock_timeout: 15
  install_tree: '$HOME/install-tree'
  module_roots:
    tcl: '$HOME/install-tree/modules'
  source_cache: '$HOME/source-cache'
  build_stage:
  - '$HOME/stage'
EOF

	if [ "$SPACK_CCACHE" = "true" ]
	then
		echo "*** Enabling ccache"
		echo "  ccache: true" >>"$HOME/.spack/config.yaml"
		ccache -o "cache_dir=$CCACHE_CACHEDIR"
		ccache -o "max_size=$CCACHE_MAXSIZE"
	fi

	if [ -n "$SPACK_BUILD_JOBS" ]
	then
		# Reduce build jobs on large number of cpus because we run tests in parallel
		cpus=$(( $SPACK_BUILD_JOBS > 5 ? $SPACK_BUILD_JOBS * 2 / 3 : $SPACK_BUILD_JOBS ))
		echo "  build_jobs: $cpus" >>"$HOME/.spack/config.yaml"
	fi

	cat "$HOME/.spack/config.yaml"
	mkdir -v -p "$HOME/install-tree"
	mkdir -v -p "$HOME/stage"

	. thisfairsoft.sh --setup

	if (hostname --all-fqdns 2>/dev/null || hostname -f) | grep '[.]gsi[.]de *$' >/dev/null
	then
		spack mirror add test http://citpc008.gsi.de/spack/source-cache
	fi
else
	. thisfairsoft.sh
fi
