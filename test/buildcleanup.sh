#! /bin/bash

. test/buildsetup.sh

installedMB="$(cd "$FS_TEST_INSTALLTREE" && du -ms . | sed -e 's/[	 ].*$//')"
# rm -rf "$FS_TEST_INSTALLTREE"

# stageKB="$(cd $FS_TEST_WORKDIR/stage && du -ks . | sed -e 's/[	 ].*$//')"
(cd "$FS_TEST_WORKDIR" && du -sch *)

(cd "$FS_TEST_WORKDIR" && tar -cjf "stage.tar.bz2" stage) \
	&& mv "$FS_TEST_WORKDIR/stage.tar.bz2" "$CMAKE_BINARY_DIR/" \
	&& ls -l "$CMAKE_BINARY_DIR/stage.tar.bz2" \
	&& rm -rf "$FS_TEST_WORKDIR/stage"


echo ""
echo "<DartMeasurement name=\"installedMB\" type=\"numeric/double\">$installedMB</DartMeasurement>"
# echo "<DartMeasurement name=\"stageKB\" type=\"numeric/double\">$stageKB</DartMeasurement>"
