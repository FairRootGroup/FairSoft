# Copyright 2013-2020 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)


from spack import *


class G4radioactivedecay(Package):
    """Geant4 data files for radio-active decay hadronic processes"""
    homepage = "http://geant4.web.cern.ch"
    url = "http://geant4-data.web.cern.ch/geant4-data/datasets/G4RadioactiveDecay.5.1.1.tar.gz"

    tags = ['hep']

    maintainers = ['drbenmorgan']

    # Only versions relevant to Geant4 releases built by spack are added
    version('5.6', sha256='3886077c9c8e5a98783e6718e1c32567899eeb2dbb33e402d4476bc2fe4f0df1')
    version('5.4', sha256='240779da7d13f5bf0db250f472298c3804513e8aca6cae301db97f5ccdcc4a61')
    version('5.3', sha256='5c8992ac57ae56e66b064d3f5cdfe7c2fee76567520ad34a625bfb187119f8c1')
    version('5.2', sha256='99c038d89d70281316be15c3c98a66c5d0ca01ef575127b6a094063003e2af5d')
    version('5.1.1', sha256='f7a9a0cc998f0d946359f2cb18d30dff1eabb7f3c578891111fc3641833870ae')

    def install(self, spec, prefix):
        mkdirp(join_path(prefix.share, 'data'))
        install_path = join_path(prefix.share, 'data',
                                 'RadioactiveDecay{0}'
                                 .format(self.version))
        install_tree(self.stage.source_path, install_path)

    def setup_dependent_run_environment(self, env, dependent_spec):
        install_path = join_path(self.prefix.share, 'data',
                                 'RadioactiveDecay{0}'
                                 .format(self.version))
        env.set('G4RADIOACTIVEDATA', install_path)

    def url_for_version(self, version):
        """Handle version string."""
        return ("http://geant4-data.web.cern.ch/geant4-data/datasets/G4RadioactiveDecay.%s.tar.gz" % version)
