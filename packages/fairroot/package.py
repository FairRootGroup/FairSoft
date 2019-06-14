from spack import *
#import platform
#import compiler


class Fairroot(CMakePackage):
    """C++ simulation, reconstruction and analysis framework for particle physics experiments """


    homepage = "http://fairroot.gsi.de"
    url      = "https://github.com/FairRootGroup/FairRoot/archive/v18.0.6.tar.gz"
    git      = "https://github.com/FairRootGroup/FairRoot.git"

    version('dev', branch='dev')

    # Development versions
#    version('18.0.6', '822902c2fc879eab82fca47eccb14259')

    # Add dependencies for dev version
    depends_on('gnutls ~guile', when="@dev") #dependency of cmake which has to be build without guile support
    depends_on('cmake@3.13.3 +ownlibs', when="@dev")
    depends_on('googletest@1.8.1', when="@dev")
    depends_on('boost@1.68.0 cxxstd=11 +container', when="@dev")

    depends_on('pythia6@428-alice1', when="@dev")
    depends_on('pythia8@8212', when="@dev")

    depends_on('geant4@10.05 cxxstd=11 ~qt~vecgeom~opengl~x11~motif+threads+data~clhep', when="@dev")

    # mesa and libxml2 are dependencies of root which have to be build extra due to the
    # extra build options
    depends_on('mesa~llvm', when="@dev")
    depends_on('libxml2+python', when="@dev")
    depends_on('root@6.16.00 cxxstd=11 +fortran+gdml+http+memstat+pythia6+pythia8+vc+xrootd+python~vdt', when="@dev")

    depends_on('geant3@v2-7_fairsoft', when="@dev")
    depends_on('vgm@4-5', when="@dev")
    depends_on('geant4_vmc@4-0-p1', when="@dev")

    depends_on('fairlogger@1.4.0', when="@dev")
    depends_on('fairmq@1.4.3', when="@dev")

#    depends_on('protobuf@3.4.0')
#    depends_on('flatbuffers@1.9.0')
#    depends_on('millepede')

    patch('CMake.patch', level=0, when="@18.0.6")

    def setup_environment(self, spack_env, run_env):
        spack_env.append_flags('CXXFLAGS', '-std=c++11')

    def cmake_args(self):
        spec = self.spec
        options = []
        options.append('-DROOTSYS={0}'.format(
        self.spec['root'].prefix))
        options.append('-DROOT_CONFIG_SEARCHPATH={0}'.format(
        self.spec['root'].prefix))
#        options.append('-D={0}'.format(
#        self.spec[''].prefix))
        options.append('-DPythia6_LIBRARY_DIR={0}/lib'.format(
        self.spec['pythia6'].prefix))
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
        options.append('-DDISABLE_GO=ON')
        options.append('-DBUILD_EXAMPLES=OFF')
        options.append('-DFAIRROOT_MODULAR_BUILD=ON')
        options.append('-DBoost_NO_SYSTEM_PATHS=TRUE')
        options.append('-DCMAKE_EXPORT_COMPILE_COMMANDS=ON')

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

