#! /bin/bash

echo "*** Setting things up:"

. test/buildsetup.sh


function handle_gitdifflist() {
	while read -d "" filename
	do
		echo "*** Looking at '$filename'"
		case "$filename" in
			packages/*)
				pkg="${filename#packages/}"
				pkg="${pkg%%/*}"
				echo "    Would uninstall '$pkg'"
				;;
			spack)
				echo "    spack was changed, needing to wipe everything"
				;;
			env/*.yaml)
				echo "    Ignoring"
				;;
			*)
				echo "    Don't know about this one"
				;;
		esac
	done
}


if [ -n "$CHANGE_ID" -a -n "$CHANGE_TARGET" ]
then
	echo "*** Trying to list changed files (origin/$CHANGE_TARGET -> HEAD)"
	git diff --name-only "origin/$CHANGE_TARGET" HEAD --
	echo "*** Analyzing list and acting"
	git diff --name-only -z "origin/$CHANGE_TARGET" HEAD -- \
		| handle_gitdifflist
fi
