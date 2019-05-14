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

    depends_on('googletest')
    depends_on('boost')
    depends_on('fairlogger')
    depends_on('zeromq')
    depends_on('msgpack-c')
#    depends_on('')
#    depends_on('')
    

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
        options.append('-DBUILD_DDS_PLUGIN=OFF')

        return options



#      ${CXXSTD:+-DCMAKE_CXX_STANDARD=$CXXSTD}

#      ${DDS_ROOT:+-DDDS_ROOT=$DDS_ROOT}                          \
#      ${ASIOFI_ROOT:+-DASIOFI_ROOT=$ASIOFI_ROOT}                 \
#      ${OFI_ROOT:+-DOFI_ROOT=$OFI_ROOT}                          \
#      ${OFI_ROOT:--DBUILD_OFI_TRANSPORT=OFF}                     \
##      -DDISABLE_COLOR=ON                                         \
#      -DBUILD_DDS_PLUGIN=ON                                      \
#      -DBUILD_NANOMSG_TRANSPORT=OFF                              \
#      ${BUILD_OFI:+-DBUILD_OFI_TRANSPORT=ON}                     \
#      -DCMAKE_INSTALL_BINDIR=bin