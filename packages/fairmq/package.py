# Copyright 2019 GSI Helmholtz Centre for Heavy Ion Research
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack import *


class Fairmq(CMakePackage):
    """C++ Message Queuing Library and Framework"""

    homepage = 'https://github.com/FairRootGroup/FairMQ'
    url = 'https://github.com/FairRootGroup/FairMQ/archive/v1.2.3.tar.gz'
    git = 'https://github.com/FairRootGroup/FairMQ.git'

    version('dev', branch='dev')
    version('1.4.3', '6659f281bdf07158935a878b34457466')
    version('1.2.3', '53f0d597d622eeb2b3f50a16d9ed7bbe')

    # Fix dependencies for FairMQ 1.2.3
    depends_on('googletest@1.7.0:', when='@1.2.3')
    depends_on('googletest@1.8.1', when='@1.4.3')
    depends_on('googletest@1.8.1', when='@dev')

    depends_on('boost@1.67.0 cxxstd=11', when='@1.2.3')
    depends_on('boost@1.68.0 cxxstd=11 +container', when='@1.4.3')
    depends_on('boost@1.70.0 cxxstd=11 +container', when='@dev')

    depends_on('fairlogger@1.2.0', when='@1.2.3')
    depends_on('fairlogger@1.4.0', when='@1.4.3')
    depends_on('fairlogger@1.4.0', when='@dev')

    depends_on('zeromq@4.2.5', when='@1.2.3')
    depends_on('zeromq@4.3.1', when='@1.4.3')
    depends_on('zeromq@4.3.1', when='@dev')

    depends_on('msgpack-c@2.1.5', when='@1.2.3')
    depends_on('msgpack-c@3.1.1', when='@1.4.3')
    depends_on('msgpack-c@3.1.1', when='@dev')

    depends_on('dds@2.1-1-g181b66a', when='@1.2.3')
    depends_on('dds@2.2', when='@1.4.3')
    depends_on('dds@master', when='@dev')

    depends_on('nanomsg@1.0.0', when='@1.2.3')
    depends_on('nanomsg@1.1.5', when='@1.4.3')
    depends_on('nanomsg@1.1.5', when='@dev')

    depends_on('flatbuffers', when='@dev')

    def cmake_args(self):
        spec = self.spec
        options = []
        options.append('-DGTEST_ROOT={0}'.format(
            self.spec['googletest'].prefix))
        options.append('-DBOOST_ROOT={0}'.format(self.spec['boost'].prefix))
        options.append('-DFAIRLOGGER_ROOT={0}'.format(
            self.spec['fairlogger'].prefix))
        options.append('-DZEROMQ_ROOT={0}'.format(self.spec['zeromq'].prefix))
        options.append('-DMSGPACK_ROOT={0}'.format(
            self.spec['msgpack-c'].prefix))
        options.append('-DDDS_ROOT={0}'.format(self.spec['dds'].prefix))
        options.append('-DBUILD_DDS_PLUGIN=ON')
        options.append('-DNANOMSG_ROOT={0}'.format(
            self.spec['nanomsg'].prefix))
        options.append('-DBUILD_NANOMSG_TRANSPORT=ON')
        if self.spec.satisfies('@dev'):
            options.append('-DBUILD_SDK=ON')
            options.append('-DBUILD_SDK_COMMANDS=ON')

        return options

    def patch(self):
        """Spack strips the git repository, but the version is determined
           by querying the git repository. This patches the CMake code to
           not rely on a successful git query for the version info any more."""
        filter_file('get_git_version\(\)',
                    'get_git_version(DEFAULT_VERSION %s)' % self.spec.version,
                    'CMakeLists.txt')

    def setup_dependent_build_environment(self, env, dependent_spec):
        """Prepend this package to the CMAKE_PREFIX_PATH"""
        env.prepend_path('CMAKE_PREFIX_PATH', self.prefix)
