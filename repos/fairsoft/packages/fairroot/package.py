# Copyright 2013-2020 Lawrence Livermore National Security, LLC and other
#   Spack Project Developers. See the top-level COPYRIGHT file for details.
# Copyright 2020 GSI Helmholtz Centre for Heavy Ion Research GmbH,
#   Darmstadt, Germany
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack import *
#import platform
#import compiler


class Fairroot(CMakePackage):
    """C++ simulation, reconstruction and analysis framework for particle physics experiments """

    homepage = "http://fairroot.gsi.de"
    url      = "https://github.com/FairRootGroup/FairRoot/archive/v18.4.0.tar.gz"
    git      = "https://github.com/FairRootGroup/FairRoot.git"

    # Development versions
    version('develop', branch='dev')

    version('18.4.0', sha256='97ad86d039db195acf12e9978eb660daab0c91e95e517921bac5a0f157a3e309')
    version('18.2.1', sha256='a9c22965d2d99e385f64c0df1867b477b9c129bcd087ba3b683d0ada6f3d66d0')

    variant('cxxstd',
            default='11',
            values=('11', '14', '17'),
            multi=False,
            description='Use the specified C++ standard when building.')

    variant('sim', default=True, description='Enable simulation engines and event generators')
    variant('examples', default=False, description='Install examples')

    # Dependencies which are same for all versions
    depends_on('cmake@3.13.4:', type='build')
    depends_on('googletest@1.8.1:')

    depends_on('pythia6', when='+sim')
    depends_on('pythia8', when='+sim')

    # mesa and libxml2 are dependencies of root which have to be build extra due to the
    # extra build options
    depends_on('libxml2~python')

    # Dependencies for dev version
    depends_on('boost@1.68.0: cxxstd=11 +container')

    depends_on('vmc', when='@18.4: ^root@6.18:')

    depends_on('geant4', when="+sim")

    depends_on('root+http')

    depends_on('geant3', when="+sim")
    depends_on('vgm', when="+sim")
    depends_on('geant4-vmc', when="+sim")

    depends_on('fairlogger@1.4.0:')
    depends_on('fairmq@1.4.11:')

    depends_on('protobuf')
    depends_on('flatbuffers')
#    depends_on('millepede')
    depends_on('yaml-cpp', when='@18.2:')

    depends_on('fairsoft-config', when='@:18,develop')

    patch('cmake_utf8.patch', when='@18.2.1')
    patch('fairlogger_incdir.patch', level=0, when='@18.2.1')

    def setup_build_environment(self, env):
        super(Fairroot, self).setup_build_environment(env)
        stdversion=('-std=c++%s' % self.spec.variants['cxxstd'].value)
        env.append_flags('CXXFLAGS', '-std=c++%s' % self.spec.variants['cxxstd'].value)
        env.unset('SIMPATH')
        env.unset('FAIRSOFT_ROOT')

    def cmake_args(self):
        spec = self.spec
        options = []
        options.append('-DROOTSYS={0}'.format(
        self.spec['root'].prefix))
        options.append('-DROOT_CONFIG_SEARCHPATH={0}'.format(
        self.spec['root'].prefix))
        options.append('-DPythia6_LIBRARY_DIR={0}/lib'.format(
        self.spec['pythia6'].prefix))
        options.append('-DPYTHIA8_DIR={0}'.format(self.spec['pythia8'].prefix))
        options.append('-DGeant3_DIR={0}'.format(
        self.spec['geant3'].prefix))
        options.append('-DGeant4_DIR={0}'.format(
        self.spec['geant4'].prefix))
        options.append('-DBOOST_ROOT={0}'.format(
        self.spec['boost'].prefix))
        options.append('-DBOOST_INCLUDEDIR={0}/include'.format(
        self.spec['boost'].prefix))
        options.append('-DBOOST_LIBRARYDIR={0}/lib'.format(
        self.spec['boost'].prefix))
        options.append('-DFlatbuffers_DIR={0}'.format(
        self.spec['flatbuffers'].prefix))
        options.append('-DDISABLE_GO=ON')
        options.append('-DBUILD_EXAMPLES:BOOL=%s' %
                       ('ON' if '+examples' in self.spec else 'OFF'))
        options.append('-DFAIRROOT_MODULAR_BUILD=ON')
        options.append('-DCMAKE_EXPORT_COMPILE_COMMANDS=ON')
        if self.spec.satisfies('^boost@:1.69.99'):
            options.append('-DBoost_NO_BOOST_CMAKE=ON')

        return options

#        ${DDS_ROOT:+-DDDS_PATH=$DDS_ROOT}                                                     \
#        ${GSL_ROOT:+-DGSL_DIR=$GSL_ROOT}                                                      \
#        ${PROTOBUF_ROOT:+-DProtobuf_LIBRARY=$PROTOBUF_ROOT/lib/libprotobuf.$SONAME}           \
#        ${PROTOBUF_ROOT:+-DProtobuf_LITE_LIBRARY=$PROTOBUF_ROOT/lib/libprotobuf-lite.$SONAME} \
#        ${PROTOBUF_ROOT:+-DProtobuf_PROTOC_LIBRARY=$PROTOBUF_ROOT/lib/libprotoc.$SONAME}      \
#        ${PROTOBUF_ROOT:+-DProtobuf_INCLUDE_DIR=$PROTOBUF_ROOT/include}                       \
#        ${PROTOBUF_ROOT:+-DProtobuf_PROTOC_EXECUTABLE=$PROTOBUF_ROOT/bin/protoc}              \
#        ${CXXSTD:+-DCMAKE_CXX_STANDARD=$CXXSTD}                                               \

#    def install(self, spec, prefix):
#        # touch a file in the installation directory
#        touch('%s/this-is-a-bundle.txt' % prefix)

    def common_env_setup(self, env):
        # So that root finds the shared library / rootmap
        env.prepend_path("LD_LIBRARY_PATH", self.prefix.lib)

    def setup_run_environment(self, env):
        self.common_env_setup(env)

    def setup_dependent_build_environment(self, env, dependent_spec):
        self.common_env_setup(env)

    def setup_dependent_run_environment(self, env, dependent_spec):
        self.common_env_setup(env)
