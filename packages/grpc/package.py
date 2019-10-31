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
#     spack install grpc
#
# You can edit this file again by typing:
#
#     spack edit grpc
#
# See the Spack documentation for more information on packaging.
# ----------------------------------------------------------------------------

from spack import *


class Grpc(CMakePackage):
    """FIXME: Put a proper description of your package here."""

    # FIXME: Add a proper url for your package's homepage here.
    homepage = "http://www.example.com"
    url      = "https://github.com/grpc/grpc/archive/v1.24.3.tar.gz"

    version('1.25.0-pre1', sha256='032564aaed8ab11099c04a7f75810ccd86fa52b38307fe45c2b3e45975ac40a6')
    version('1.24.3',      sha256='c84b3fa140fcd6cce79b3f9de6357c5733a0071e04ca4e65ba5f8d306f10f033', preferred=True)
    version('1.24.2',      sha256='fd040f5238ff1e32b468d9d38e50f0d7f8da0828019948c9001e9a03093e1d8f')
    version('1.24.1',      sha256='ffadb8c6bcd725b60c370484062363c4c476335fbd5f377dcc66ac9c91aeae03')
    version('1.24.0-pre2', sha256='659130c927c53afb537ecc178134bfa565435d619153fd0a2baae0757e69b97e')
    version('1.24.0-pre1', sha256='b80dbfac0438013c1ac938731b80fb4f1d98459ae9f3c6131490c19924205732')
    version('1.24.0',      sha256='03a22a2fbfec8ccc44ff2e8061c312c9b4a0d33046b6d0c84c8eca5c56569387')
    version('1.23.1',      sha256='dd7da002b15641e4841f20a1f3eb1e359edb69d5ccf8ac64c362823b05f523d9')
    version('1.23.0',      sha256='f56ced18740895b943418fa29575a65cc2396ccfa3159fa40d318ef5f59471f9')
    version('1.22.1',      sha256='cce1d4585dd017980d4a407d8c5e9f8fc8c1dbb03f249b99e88a387ebb45a035')

    depends_on('c-ares')
    depends_on('gflags')
    depends_on('protobuf')
    depends_on('benchmark')
    depends_on('zlib')

    patch('grpc_cmake.patch', level=1, when='@1.24.3')

    def cmake_args(self):
        args = []
        return args
