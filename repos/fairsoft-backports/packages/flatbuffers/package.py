# Copyright 2013-2020 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack import *


class Flatbuffers(CMakePackage):
    """Memory Efficient Serialization Library
    """

    homepage = "http://google.github.io/flatbuffers/"
    url      = "https://github.com/google/flatbuffers/archive/v1.9.0.tar.gz"
    git = 'https://github.com/google/flatbuffers.git'

    version('1.12.0', sha256='62f2223fb9181d1d6338451375628975775f7522185266cd5296571ac152bc45')
    version('1.11.0', sha256='3f4a286642094f45b1b77228656fbd7ea123964f19502f9ecfd29933fd23a50b')

    # Silence false positive "-Wstringop-overflow" on GCC 10.0 to 11.0
    # https://github.com/google/flatbuffers/commit/515a4052a750dfe6df8d143c8f23cd8aaf51f9d7
    patch('silence_false_positive_gcc10_warning.patch', when='@:1.12.0%gcc@10:11')

    @when('@1.12.0')
    def patch(self):
        filter_file(r' -Werror -W', r' -W', 'CMakeLists.txt')

    def cmake_args(self):
        args = []
        args.append('-DFLATBUFFERS_BUILD_SHAREDLIB=ON')
        args.append('-DFLATBUFFERS_BUILD_FLATLIB=OFF')
        args.append('-DCMAKE_BUILD_TYPE=Release')
        if 'darwin' in self.spec.architecture:
            args.append('-DCMAKE_MACOSX_RPATH=ON')
        return args
