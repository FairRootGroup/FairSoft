#! /bin/bash

if [ -z "$LABEL" ]
then
	if which lsb_release >/dev/null
	then
		export LABEL="$(lsb_release -s -i)-$(lsb_release -s -r)"
	fi
fi

# echo "==> Environment:"
# env | sed -e 's/^/==>  | /'

if [ ! -d "$TARGETDIR" ]
then
	TARGETDIR="$(mktemp -d)"
	echo "==> Created test directory: $TARGETDIR"
else
	echo "==> Reusing test directory: $TARGETDIR"
fi

export HOME="$TARGETDIR"

if [ ! -d "$HOME/.spack/" ]
then
	echo "==> Setting up spack"
	mkdir -p "$HOME/.spack/"
	cat >"$HOME/.spack/config.yaml" <<EOF
config:
  install_tree: '$HOME/install-tree'
  module_roots:
    tcl: '$HOME/install-tree/modules'
  source_cache: '$HOME/source-cache'
EOF

	. spack/share/spack/setup-env.sh

	spack mirror add test http://citpc008.gsi.de/spack/source-cache
	spack repo add .
else
	. spack/share/spack/setup-env.sh
fi
