# Copyright 2013-2019 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)


from spack import *
import os


class G4tendl(Package):
    """Geant4 data for incident particles [optional]"""
    homepage = "http://geant4.web.cern.ch"
    url = "http://geant4-data.web.cern.ch/geant4-data/datasets/G4TENDL.1.3.tar.gz"

    version('1.3', '52ad77515033a5d6f995c699809b464725a0e62099b5e55bf07c8bdd02cd3bce')
    version('1.3.2', '3b2987c6e3bee74197e3bd39e25e1cc756bb866c26d21a70f647959fc7afb849')

    def install(self, spec, prefix):
        mkdirp(join_path(prefix.share, 'data'))
        install_path = join_path(prefix.share, 'data',
                                 os.path.basename(self.stage.source_path))
        install_tree(self.stage.source_path, install_path)

    def url_for_version(self, version):
        """Handle version string."""
        return ("http://geant4-data.web.cern.ch/geant4-data/datasets/G4TENDL.%s.tar.gz" % version)
