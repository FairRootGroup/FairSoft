# Copyright 2013-2020 Lawrence Livermore National Security, LLC and other
#   Spack Project Developers. See the top-level COPYRIGHT file for details.
# Copyright 2020 GSI Helmholtz Centre for Heavy Ion Research GmbH,
#   Darmstadt, Germany
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack import *


class R3broot(CMakePackage):
    git = 'https://github.com/R3BRootGroup/R3BRoot'
    homepage = 'https://github.com/R3BRootGroup/R3BRoot'

    version('develop', branch='dev')

    resource(name='macros', when='@develop',
             git='https://github.com/R3BRootGroup/macros',
             branch='dev')

    depends_on('fairroot')

    depends_on('fairlogger')
    depends_on('geant3')
    depends_on('geant4~threads')
    depends_on('geant4-vmc')
    depends_on('pythia6')
    depends_on('pythia8')

    patch('fairlogger_include.patch')
    patch('no_boost_loading.patch')

    def cmake_args(self):
        args = ['-DCMAKE_CXX_STANDARD=11']
        return args

    def build(self, spec, prefix):
        super(R3broot, self).build(spec, prefix)
        with working_dir(self.build_directory):
            make("CTEST_OUTPUT_ON_FAILURE=1", "test")

    def setup_build_environment(self, env):
        env.set("FAIRROOTPATH", self.spec['fairroot'].prefix)
        env.set("SIMPATH", self.spec["fairroot"].prefix)
        env.unset('FAIRSOFT_ROOT')
        env.append_path('CPATH', self.spec['fairlogger'].prefix.include)
