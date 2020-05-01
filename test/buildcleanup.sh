#! /bin/bash

. test/buildsetup.sh

installedMB="$(cd $HOME/install-tree && du -ms . | sed -e 's/[	 ].*$//')"
rm -rf "$HOME/install-tree"

# stageKB="$(cd $HOME/stage && du -ks . | sed -e 's/[	 ].*$//')"
(cd "$HOME" && du -sh stage)
(cd "$HOME" && tar -cjf "stage.tar.bz2" stage) \
	&& mv "$HOME/stage.tar.bz2" "$CMAKE_BINARY_DIR/" \
	&& ls -l "$CMAKE_BINARY_DIR/stage.tar.bz2" \
	&& rm -rf "$HOME/stage"

echo ""
echo "<DartMeasurement name=\"installedMB\" type=\"numeric/double\">$installedMB</DartMeasurement>"
# echo "<DartMeasurement name=\"stageKB\" type=\"numeric/double\">$stageKB</DartMeasurement>"
