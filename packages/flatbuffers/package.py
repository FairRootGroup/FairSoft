# Copyright 2013-2019 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack import *


class Flatbuffers(CMakePackage):
    """Memory Efficient Serialization Library
    """

    homepage = "http://google.github.io/flatbuffers/"
    url      = "https://github.com/google/flatbuffers/archive/v1.9.0.tar.gz"

    version('1.10.0', '3714e3db8c51e43028e10ad7adffb9a36fc4aa5b1a363c2d0c4303dd1be59a7c')
    version('1.9.0', '8be7513bf960034f6873326d09521a4b')
    version('1.9.0-fairroot', '2b1444e48b87e9d138ee7219c45f25cd')
    version('1.8.0', '276cab8303c4189cbe3b8a70e0515d65')


    def url_for_version(self, version):
        if version == Version("1.9.0-fairroot"):
            url = "https://github.com/FairRootGroup/flatbuffers/archive/v1.9.0-fairroot.tar.gz"
        else:
            url = "https://github.com/google/flatbuffers/archive/v{0}.tar.gz"
        return url.format(version)
                                                    