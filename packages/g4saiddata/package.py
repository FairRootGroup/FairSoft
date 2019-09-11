# Copyright 2013-2019 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)


from spack import *
import os


class G4saiddata(Package):
    """Geant4 data from evaluated cross-sections in SAID data-base """
    homepage = "http://geant4.web.cern.ch"
    url = "http://geant4-data.web.cern.ch/geant4-data/datasets/G4SAIDDATA.1.1.tar.gz"

    version('1.1', 'a38cd9a83db62311922850fe609ecd250d36adf264a88e88c82ba82b7da0ed7f')
    version('2.0', '1d26a8e79baa71e44d5759b9f55a67e8b7ede31751316a9e9037d80090c72e91')

    def install(self, spec, prefix):
        mkdirp(join_path(prefix.share, 'data'))
        dest = 'G4SAIDDATA' + '{0}'.format(self.version)
        install_path = join_path(prefix.share, 'data', dest)
        install_tree(self.stage.source_path, install_path)

    def url_for_version(self, version):
        """Handle version string."""
        return "http://geant4-data.web.cern.ch/geant4-data/datasets/G4SAIDDATA.%s.tar.gz" % version
