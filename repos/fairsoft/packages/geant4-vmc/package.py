# Copyright 2013-2021 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack import *


class Geant4Vmc(CMakePackage):
    """Geant4 VMC implements the Virtual Monte Carlo (VMC) for Geant4"""

    homepage = "https://github.com/vmc-project/geant4_vmc"
    url      = "https://github.com/vmc-project/geant4_vmc/archive/v3-6.tar.gz"

    tags = ['hep']

    version('5-3',    sha256='22f58530963988380509a7741ad6b3dde21806f3862fb55c11cc27f25d3d3c2d')
    version('5-2',    sha256='5bd0e4a4f938048b35724f06075952ecfbc8a97ffc979630cfe2788323845b13')
    version('5-1-p1', sha256='2e3e4705134ea464e993156f71d478cb7d3817f5b6026bf8d9a37d32ec97590b')
    version('5-1',    sha256='ede71f360397dc4d045ec0968acf23b564fa81059c94eb40942b552eea8b5e00')
    version('5-0-p5', sha256='296340042b0bbfab0dec8f7f15a3b15cfab3fdb34aff97f80c1d52c2a25200cb')
    version('5-0-p4', sha256='0c13848b5cf5951e3d5d2d5abcc4082c75ea37c83bb92a15b82ecae03045fe1e')
    version('5-0-p3', sha256='91df73e992bf9ae7e1b6b3c3deb12cd6661c7dd5153fa233eb28b8d8e1164ccb')
    version('5-0-p2', sha256='34578c5468173615de3fc077e85be3bf68f4aff4b4f37523ab67304dbc153d5f')
    version('5-0-p1', sha256='b66cbf86a96b6efe1643753a7606b1c4ebb9d45cca9f6b8e933762920f32831f')
    version('5-0',    sha256='9a3820ea4b68b5a0697c340bbbc0972b9c8e4205ceecdd87258a9bdfd249cd8b')
    version('4-0-p1', sha256='6f1659e05a0420b471fbe6c8a6016705bc2240ada992f044071fab0eb3ef4d09')
    version('3-6',    sha256='fd54b152ba8a08216d4c4f454d019a7661198f4345cd434d1c820c347de18ec1')

    depends_on('root')
    depends_on('geant4')
    depends_on('geant4@10.5:', when='@5-0:')
    depends_on('geant4@10.6:', when='@5-2:')
    depends_on('geant4@10.7:', when='@5-3:')
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
        env.prepend_path("ROOT_LIBRARY_PATH", self.prefix.lib)

    def setup_run_environment(self, env):
        self.common_env_setup(env)

    def setup_dependent_build_environment(self, env, dependent_spec):
        self.common_env_setup(env)

    def setup_dependent_run_environment(self, env, dependent_spec):
        self.common_env_setup(env)
