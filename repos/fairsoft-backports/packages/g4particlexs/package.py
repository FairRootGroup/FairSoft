# Copyright 2013-2020 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)


from spack import *


class G4particlexs(Package):
    """Geant4 data for evaluated particle cross-sections on
    natural composition of elements"""
    homepage = "http://geant4.web.cern.ch"
    url = "http://geant4-data.web.cern.ch/geant4-data/datasets/G4PARTICLEXS.2.1.tar.gz"

    tags = ['hep']

    maintainers = ['drbenmorgan']

    # Only versions relevant to Geant4 releases built by spack are added
    version('3.1', sha256='404da84ead165e5cccc0bb795222f6270c9bf491ef4a0fd65195128b27f0e9cd')
    version('2.1', sha256='094d103372bbf8780d63a11632397e72d1191dc5027f9adabaf6a43025520b41')
    version('1.1', sha256='100a11c9ed961152acfadcc9b583a9f649dda4e48ab314fcd4f333412ade9d62')

    def install(self, spec, prefix):
        mkdirp(join_path(prefix.share, 'data'))
        install_path = join_path(prefix.share, 'data', "G4PARTICLEXS{0}"
                                 .format(self.version))
        install_tree(self.stage.source_path, install_path)

    def setup_dependent_run_environment(self, env, dependent_spec):
        install_path = join_path(self.prefix.share, 'data', 'G4PARTICLEXS{0}'
                                 .format(self.version))
        env.set('G4PARTICLEXSDATA', install_path)

    def url_for_version(self, version):
        """Handle version string."""
        return ("http://geant4-data.web.cern.ch/geant4-data/datasets/G4PARTICLEXS.%s.tar.gz" % version)
