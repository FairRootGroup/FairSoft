# Copyright 2013-2020 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack import *


class Geant4Vmc(CMakePackage):
    """Geant4 VMC implements the Virtual Monte Carlo (VMC) for Geant4"""

    homepage = "https://github.com/vmc-project/geant4_vmc"
    url = "https://github.com/vmc-project/geant4_vmc/archive/v3-6.tar.gz"

    version('5-0-p1', sha256='b66cbf86a96b6efe1643753a7606b1c4ebb9d45cca9f6b8e933762920f32831f')
    version('3-6', '01507945dfcc21827628d0eb6b233931')
    version('4-0-p1', 'd7e88a3ef11ea62bec314b5f251c91b1')
    version('5-0', sha256='9a3820ea4b68b5a0697c340bbbc0972b9c8e4205ceecdd87258a9bdfd249cd8b')

    depends_on('root')
    depends_on('geant4')
    depends_on('vgm')
    depends_on('vmc', when='@5-0:')

    patch('dict_fixes_501.patch', when='@5-0-p1')

    def cmake_args(self):
        spec = self.spec
        options = []
        options.append('-DCMAKE_INSTALL_LIBDIR:PATH=lib')
        options.append('-DGeant4VMC_USE_VGM=ON')
        options.append('-DGeant4VMC_USE_GEANT4_UI=Off')
        options.append('-DGeant4VMC_USE_GEANT4_VIS=Off')
        options.append('-DGeant4VMC_USE_GEANT4_G3TOG4=On')
        options.append('-DROOT_DIR={0}'.format(
                self.spec['root'].prefix))
        options.append('-DGeant4_DIR={0}'.format(
                self.spec['geant4'].prefix))
        options.append('-DCLHEP_DIR={0}'.format(
                self.spec['geant4'].prefix))
        options.append('-DVGM_DIR={0}'.format(
                self.spec['vgm'].prefix))
        options.append('-DWITH_TEST=OFF')

        return options

    def common_env_setup(self, env):
        # So that root finds the shared library / rootmap
        env.prepend_path("LD_LIBRARY_PATH", self.prefix.lib)

    def setup_run_environment(self, env):
        self.common_env_setup(env)

    def setup_dependent_build_environment(self, env, dependent_spec):
        self.common_env_setup(env)

    def setup_dependent_run_environment(self, env, dependent_spec):
        self.common_env_setup(env)
