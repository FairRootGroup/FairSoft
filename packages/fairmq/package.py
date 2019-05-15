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

    version('1.2.3', '53f0d597d622eeb2b3f50a16d9ed7bbe')

    # add correct version info for FairLoger from github tarball
    patch('correct_version_info_1.2.3.patch', when='@1.2.3', level=0)  
        
    depends_on('googletest')
    depends_on('boost')
    depends_on('fairlogger')
    depends_on('zeromq')
    depends_on('msgpack-c')
    depends_on('dds')
    depends_on('nanomsg')

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

        return options

#      ${CXXSTD:+-DCMAKE_CXX_STANDARD=$CXXSTD}
#      ${ASIOFI_ROOT:+-DASIOFI_ROOT=$ASIOFI_ROOT}                 \
#      ${OFI_ROOT:+-DOFI_ROOT=$OFI_ROOT}                          \
#      ${OFI_ROOT:--DBUILD_OFI_TRANSPORT=OFF}                     \
##      -DDISABLE_COLOR=ON                                         \
#      ${BUILD_OFI:+-DBUILD_OFI_TRANSPORT=ON}                     \
