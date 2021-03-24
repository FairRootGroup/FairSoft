# Copyright 2013-2021 Lawrence Livermore National Security, LLC and other
#   Spack Project Developers. See the top-level COPYRIGHT file for details.
# Copyright 2020-2021 GSI Helmholtz Centre for Heavy Ion Research GmbH,
#   Darmstadt, Germany
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack import *


class Fairroot(CMakePackage):
    """C++ simulation, reconstruction and analysis framework for particle physics experiments"""

    homepage = "http://fairroot.gsi.de"
    url = "https://github.com/FairRootGroup/FairRoot/archive/v18.4.0.tar.gz"
    git = "https://github.com/FairRootGroup/FairRoot.git"

    version('develop', branch='dev')
    version('18.6.0', sha256='ece7b92c108277e78f8dd4920e5d2a7cec7323ae64b23ffa32874d711dd27a9b')
    version('18.4.1', sha256='d8455c4bb705a2d5989ad947ffc50bb2f0d00affb649bb5e30d9463b5be0b490')
    version('18.4.0', sha256='97ad86d039db195acf12e9978eb660daab0c91e95e517921bac5a0f157a3e309')
    version('18.2.1', sha256='a9c22965d2d99e385f64c0df1867b477b9c129bcd087ba3b683d0ada6f3d66d0')

    variant('cxxstd', default='11', values=('11', '14', '17'), multi=False,
            description='Use the specified C++ standard when building.')
    variant('sim', default=True,
            description='Enable simulation engines and event generators')
    variant('examples', default=False,
            description='Install examples')

    depends_on('cmake@3.13.4:', type='build')
    depends_on('boost@1.68.0: +container')
    depends_on('fairlogger@1.4.0:')
    depends_on('fairmq@1.4.11:')
    depends_on('fairsoft-config', when='@:18,develop')
    depends_on('flatbuffers')
    depends_on('geant3', when="+sim")
    depends_on('geant4', when="+sim")
    depends_on('geant4-vmc', when="+sim")
    depends_on('googletest@1.7.0:')
    depends_on('msgpack-c@3.1:', when='+examples')
    depends_on('protobuf')
    depends_on('pythia6', when='+sim')
    depends_on('pythia8', when='+sim')
    depends_on('root+http+xml+gdml')
    depends_on('vgm', when="+sim")
    depends_on('vmc', when='@18.4: ^root@6.18:')
    depends_on('yaml-cpp', when='@18.2:')
    for std in ('11', '14', '17'):
        for dep in ('root', 'fairmq'):
            depends_on('{0} cxxstd={1}'.format(dep, std),
                       when='cxxstd={0} ^{1}'.format(std, dep))

    patch('cmake_utf8.patch', when='@18.2.1')
    patch('fairlogger_incdir.patch', level=0, when='@18.2.1')
    patch('find_pythia8_cmake.patch', when='@:18.4.0 +sim')
    patch('support_geant4_with_external_clhep_18.2.patch', when='@18.2 +sim')
    patch('support_geant4_with_external_clhep.patch', when='@18.4 +sim ^Geant4@:10.5')
    # https://github.com/FairRootGroup/FairRoot/pull/1038
    patch('drop_cxx_flag_check.patch', when='@18.4.0:18.4.2')

    def setup_build_environment(self, env):
        super(Fairroot, self).setup_build_environment(env)
        if self.spec.satisfies('@:18.3'):
            env.append_flags('CXXFLAGS',
                '-std=c++%s' % self.spec.variants['cxxstd'].value)
        env.unset('SIMPATH')
        env.unset('FAIRSOFT_ROOT')

    def cmake_args(self):
        options = []
        if self.spec.satisfies('@18.4:'):
            cxxstd = self.spec.variants['cxxstd'].value
            if cxxstd != 'default':
               options.append('-DCMAKE_CXX_STANDARD={0}'.format(cxxstd))
        if self.spec.satisfies('@:18,develop'):
            options.append('-DROOTSYS={0}'.format(self.spec['root'].prefix))
            options.append('-DPYTHIA8_DIR={0}'.format(
                self.spec['pythia8'].prefix))

        options.append('-DBUILD_EXAMPLES:BOOL=%s' %
                       ('ON' if '+examples' in self.spec else 'OFF'))

        if self.spec.satisfies('^boost@:1.69.99'):
            options.append('-DBoost_NO_BOOST_CMAKE=ON')

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
