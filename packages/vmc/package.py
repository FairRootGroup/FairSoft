# Copyright 2013-2020 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack import *


class Vmc(CMakePackage):
    """The Virtual Monte Carlo core library"""

    homepage = "https://github.com/vmc-project/vmc"
    git      = 'https://github.com/vmc-project/vmc.git'
    url      = "https://github.com/vmc-project/vmc/archive/v1-0.tar.gz"

    version('1-0-p1', sha256='4a20515f7de426797955cec4a271958b07afbaa330770eeefb5805c882ad9749')
    version('1-0', sha256='3da58518b32db1b503082e3205884802a1a263a915071b96e3fd67861db3ca40')

    patch('dict_fixes_101.patch', when='@1-0-p1')

    depends_on('root@6.18.04:')

    def common_env_setup(self, env):
        # So that root finds the shared library / rootmap
        env.prepend_path("LD_LIBRARY_PATH", self.prefix.lib)

    def setup_run_environment(self, env):
        self.common_env_setup(env)

    def setup_dependent_build_environment(self, env, dependent_spec):
        self.common_env_setup(env)

    def setup_dependent_run_environment(self, env, dependent_spec):
        self.common_env_setup(env)
