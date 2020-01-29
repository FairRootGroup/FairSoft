#! /bin/bash

. test/buildsetup.sh

installedMB="$(cd $HOME/install-tree && du -ms . | sed -e 's/[	 ].*$//')"
rm -rf "$HOME/install-tree"

stageKB="$(cd $HOME/stage && du -ks . | sed -e 's/[	 ].*$//')"

echo ""
echo "<DartMeasurement name=\"installedMB\" type=\"numeric/integer\">$installedMB</DartMeasurement>"
echo "<DartMeasurement name=\"stageKB\" type=\"numeric/integer\">$stageKB</DartMeasurement>"
