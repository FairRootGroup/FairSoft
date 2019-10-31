# Copyright 2013-2019 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

# ----------------------------------------------------------------------------
# If you submit this package back to Spack as a pull request,
# please first remove this boilerplate and all FIXME comments.
#
# This is a template package file for Spack.  We've put "FIXME"
# next to all the things you'll want to change. Once you've handled
# them, you can save this file and test your package like this:
#
#     spack install geant3
#
# You can edit this file again by typing:
#
#     spack edit geant3
#
# See the Spack documentation for more information on packaging.
# ----------------------------------------------------------------------------

from spack import *


class Fairmq(CMakePackage):
    """Lightweight and fast C++ Logging Library"""

    # FIXME: Add a proper url for your package's homepage here.
    homepage = "https://github.com/FairRootGroup/FairMQ"
    url      = "https://github.com/FairRootGroup/FairMQ/archive/v1.2.3.tar.gz"
    git      = "https://github.com/FairRootGroup/FairMQ.git"

    version('dev', branch='dev')
    version('1.4.3', '6659f281bdf07158935a878b34457466')
    version('1.2.3', '53f0d597d622eeb2b3f50a16d9ed7bbe')

    # add correct version info for FairLoger from github tarball
    patch('correct_version_info_1.2.3.patch', when='@1.2.3', level=0)
    patch('correct_version_info_1.4.3.patch', when='@1.4.3', level=0)
    patch('correct_version_info_1.4.6.patch', when='@dev', level=1)

    # Fix dependencies for FairMQ 1.2.3
    depends_on("googletest@1.7.0:", when="@1.2.3")
    depends_on("googletest@1.8.1", when="@1.4.3")
    depends_on("googletest@1.8.1", when="@dev")

    depends_on("boost@1.67.0 cxxstd=11", when="@1.2.3")
    depends_on("boost@1.68.0 cxxstd=11 +container", when="@1.4.3")
    depends_on("boost@1.70.0 cxxstd=11 +container", when="@dev")

    depends_on("fairlogger@1.2.0", when="@1.2.3")
    depends_on("fairlogger@1.4.0", when="@1.4.3")
    depends_on("fairlogger@1.4.0", when="@dev")

    depends_on("zeromq@4.2.5", when="@1.2.3")
    depends_on("zeromq@4.3.1", when="@1.4.3")
    depends_on("zeromq@4.3.1", when="@dev")

    depends_on("msgpack-c@2.1.5", when="@1.2.3")
    depends_on("msgpack-c@3.1.1", when="@1.4.3")
    depends_on("msgpack-c@3.1.1", when="@dev")

    depends_on("dds@2.1-1-g181b66a", when="@1.2.3")
    depends_on("dds@2.2", when="@1.4.3")
    depends_on("dds@master", when="@dev")

    depends_on("nanomsg@1.0.0", when="@1.2.3")
    depends_on("nanomsg@1.1.5", when="@1.4.3")
    depends_on("nanomsg@1.1.5", when="@dev")

    depends_on('flatbuffers', when='@dev')

    def cmake_args(self):
        spec = self.spec
        options = []
        options.append('-DGTEST_ROOT={0}'.format(
                self.spec['googletest'].prefix))
        options.append('-DBOOST_ROOT={0}'.format(
                self.spec['boost'].prefix))
        options.append('-DFAIRLOGGER_ROOT={0}'.format(
                self.spec['fairlogger'].prefix))
        options.append('-DZEROMQ_ROOT={0}'.format(
                self.spec['zeromq'].prefix))
        options.append('-DMSGPACK_ROOT={0}'.format(
                self.spec['msgpack-c'].prefix))
        options.append('-DDDS_ROOT={0}'.format(
                self.spec['dds'].prefix))
        options.append('-DBUILD_DDS_PLUGIN=ON')
        options.append('-DNANOMSG_ROOT={0}'.format(
                self.spec['nanomsg'].prefix))
        options.append('-DBUILD_NANOMSG_TRANSPORT=ON')
        if self.spec.satisfies("@dev"):
            options.append('-DBUILD_SDK=ON')
            options.append('-DBUILD_SDK_COMMANDS=ON')

        return options

#      ${CXXSTD:+-DCMAKE_CXX_STANDARD=$CXXSTD}
#      ${ASIOFI_ROOT:+-DASIOFI_ROOT=$ASIOFI_ROOT}                 \
#      ${OFI_ROOT:+-DOFI_ROOT=$OFI_ROOT}                          \
#      ${OFI_ROOT:--DBUILD_OFI_TRANSPORT=OFF}                     \
##      -DDISABLE_COLOR=ON                                         \
#      ${BUILD_OFI:+-DBUILD_OFI_TRANSPORT=ON}                     \
