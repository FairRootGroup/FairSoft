# Copyright 2013-2020 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack import *


class Flatbuffers(CMakePackage):
    """Memory Efficient Serialization Library
    """

    homepage = "http://google.github.io/flatbuffers/"
    git = 'https://github.com/google/flatbuffers.git'

    version('1.11.0', tag='v1.11.0', commit='9e7e8cbe9f675123dd41b7c62868acad39188cae', submodules=True, no_cache=True)

    # Silence false positive "-Wstringop-overflow" on GCC 10.0 to 11.0
    # https://github.com/google/flatbuffers/commit/515a4052a750dfe6df8d143c8f23cd8aaf51f9d7
    patch('silence_false_positive_gcc10_warning.patch', when='@:1.12.0%gcc@10:11')

    def cmake_args(self):
        args=[]
        args.append('-DFLATBUFFERS_BUILD_SHAREDLIB=ON')
        args.append('-DFLATBUFFERS_BUILD_FLATLIB=OFF')
        args.append('-DCMAKE_BUILD_TYPE=Release')
        args.append('-DCMAKE_MACOSX_RPATH=ON')
        return args
