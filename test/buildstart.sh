#! /bin/bash

echo "***"
echo "***       Setting things up"
echo "***       ================="
echo "***"

. test/buildsetup.sh

echo "*** 'spack debug report'"
spack debug report | sed -e 's/^/    /'


function handle_gitdifflist() {
	while read -d "" filename
	do
		echo "***    | + '$filename'"
		case "$filename" in
			repos/*/packages/*)
				pkg="${filename#repos/*/packages/}"
				pkg="${pkg%%/*}"
				echo "***    |   uninstall '$pkg'"
				spack uninstall --all --dependents -y "$pkg"
				;;
			spack|config/*)
				echo "***    |   spack was changed, needing to wipe everything"
				( cd "$FS_TEST_INSTALLTREE" && \
					find . -mindepth 1 -maxdepth 2 -depth \
						-type d -print0 \
						| xargs -0 -n 1 -t rm -rf )
				;;
			env/*.yaml|Jenkinsfile|CMakeLists.txt|*.cmake|test/*)
				echo "***    |   Ignoring"
				;;
			*)
				echo "***    |   /!\ Don't know about this one"
				;;
		esac
	done
}


echo "*** Checking changes and deleting out-dated packages"

if [ -n "$CHANGE_ID" -a -n "$CHANGE_TARGET" ]
then
	echo "***    Comparing origin/$CHANGE_TARGET to HEAD"
	git diff --name-only -z "origin/$CHANGE_TARGET" HEAD -- \
		| handle_gitdifflist
fi

echo "***"
echo "***       Done with settings things up"
echo "***       ============================"
echo "***"
