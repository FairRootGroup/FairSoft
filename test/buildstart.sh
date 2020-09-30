#! /bin/bash

echo "***"
echo "***       Setting things up"
echo "***       ================="
echo "***"

. test/buildsetup.sh

echo "*** 'spack debug report'"
spack debug report | sed -e 's/^/    /'


function wipe_install_tree() {
	echo "***    |   Wiping complete install tree"
	( cd "$FS_TEST_INSTALLTREE" && \
		find . -mindepth 1 -maxdepth 2 -depth \
			-type d -print0 \
			| xargs -0 -n 1 -t rm -rf )
}

function handle_gitdifflist() {
	while read -d "" filename
	do
		printf "***    |-- %q" "$filename"
		case "$filename" in
			repos/*/packages/*)
				echo ""
				pkg="${filename#repos/*/packages/}"
				pkg="${pkg%%/*}"
				echo "***    |   uninstall '$pkg'"
				spack uninstall --all --dependents --force -y "$pkg"
				;;
			spack|config/*)
				echo ""
				echo "***    |   spack was changed, needing to wipe"
				wipe_install_tree
				;;
			env/*.yaml|Jenkinsfile|CMakeLists.txt|*.cmake|test/*)
				echo " : Ignoring"
				;;
			README.md|docs/*)
				echo " : Ignoring"
				;;
			*)
				echo ""
				echo "***    |   /!\ Don't know about this one"
				;;
		esac
	done
}

function showhist() {
	echo "***    |"
	git log --graph --pretty="tformat:%<|(15)%h %<(50,trunc)%s" \
	       "$1" "$2" "$(git merge-base "$1" "$2")^!" \
	       | sed -e 's/^/***    |  /'
	echo "***    |"
}


echo "*** Checking for old envs from previous runs and removing"
spack env list | sed -n -e 's/^ *//' -e 's/ *$//' -e '/^fs_test_/p' \
	| while read env
	do
		echo "***    $env"
		spack env rm -y "$env"
	done

echo "*** Checking changes and deleting out-dated packages"

if [ -n "$CHANGE_ID" -a -n "$CHANGE_TARGET" ]
then
	echo "***    Comparing origin/$CHANGE_TARGET to HEAD"
	showhist "origin/$CHANGE_TARGET" HEAD
	git diff --name-only -z "origin/$CHANGE_TARGET" HEAD -- \
		| handle_gitdifflist
fi

if [ -r "$FS_TEST_INSTALLTREE/sha1-stamps" ]
then
	cat "$FS_TEST_INSTALLTREE/sha1-stamps" | sort | uniq \
	| while read sha1
	do
		echo "***    Comparing $sha1 to worktree"
		if git rev-parse --verify "${sha1}^{object}" >/dev/null
		then
			:
		else
			echo "***    |"
			echo "***    |   /!\  Unknown commit hash, could mean broken install tree"
			echo "***    |"
			wipe_install_tree
			echo "***    |   Stopping analyzing"
			break
		fi
		showhist "${sha1}" HEAD
		git diff --name-only -z "$sha1" \
			| handle_gitdifflist
	done
fi

echo "***"
echo "***       Done with settings things up"
echo "***       ============================"
echo "***"
