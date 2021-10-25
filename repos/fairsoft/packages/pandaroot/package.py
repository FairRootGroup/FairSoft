# Copyright 2013-2021 Lawrence Livermore National Security, LLC and other
#   Spack Project Developers. See the top-level COPYRIGHT file for details.
# Copyright 2019-2021 GSI Helmholtz Centre for Heavy Ion Research GmbH,
#   Darmstadt, Germany
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)


class Pandaroot(CMakePackage):
    """Simulations and Data Analysis for Panda"""

    homepage = "https://git.panda.gsi.de/PandaRootGroup/PandaRoot"
    git      = "https://git.panda.gsi.de/PandaRootGroup/PandaRoot"

    version('develop', branch='dev')

    depends_on('fairroot')
    depends_on('root+fftw')
    depends_on('pythia8')
    depends_on('hepmc')
    depends_on('faircmakemodules')

    def setup_build_environment(self, env):
        env.set("FAIRROOTPATH", self.spec['fairroot'].prefix)
        env.set("SIMPATH", self.spec["fairroot"].prefix)
        env.set('SPACK_INCLUDE_DIRS', '', force=True)
        env.set('SPACK_LINK_DIRS', '', force=True)
        env.append_path('SPACK_LINK_DIRS', self.spec['root'].prefix.lib)
        env.append_path('SPACK_LINK_DIRS', self.spec['pythia6'].prefix.lib)
        env.append_path('SPACK_LINK_DIRS', self.spec['geant4'].prefix.lib)

    def cmake_args(self):
        options = []
        options.append('--log-level=VERBOSE')
        options.append('-DNOVC:BOOL=ON')
        return options
