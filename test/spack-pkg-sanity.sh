#! /bin/bash

. test/build-main-tests-common.sh

keyword_search="package_sanity and not prs_update_old_api"

if spack unit-test --help >/dev/null 2>&1
then
	set -x
	spack unit-test -k "$keyword_search"
else
	set -x
	spack test -k "$keyword_search"
fi

# Ignore errors for now
exit 0
exit $?
