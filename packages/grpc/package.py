# Copyright 2013-2019 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)
from spack import *


class Grpc(CMakePackage):
    """A high performance, open-source universal RPC framework."""

    homepage = "https://grpc.io"
    url      = "https://github.com/grpc/grpc/archive/v1.24.3.tar.gz"

    version('1.25.0-pre1', sha256='032564aaed8ab11099c04a7f75810ccd86fa52b38307fe45c2b3e45975ac40a6')
    version('1.24.3',      sha256='c84b3fa140fcd6cce79b3f9de6357c5733a0071e04ca4e65ba5f8d306f10f033', preferred=True)
    version('1.23.1',      sha256='dd7da002b15641e4841f20a1f3eb1e359edb69d5ccf8ac64c362823b05f523d9')

    variant('shared', default=True,
            description='Enables the build of shared libraries')
    variant('codegen', default=True,
            description='Builds code generation plugins for protobuf '
                        'compiler (protoc)')

    depends_on('protobuf')
    depends_on('openssl')
    depends_on('zlib')
    if Version(spack_version) >= Version('0.14'):
        depends_on('c-ares')
    else:
        depends_on('cares')
    depends_on('benchmark')
    depends_on('gflags')

    def cmake_args(self):
        args = [
            '-DBUILD_SHARED_LIBS:Bool={0}'.format(
                'ON' if '+shared' in self.spec else 'OFF'),
            '-DgRPC_BUILD_CODEGEN:Bool={0}'.format(
                'ON' if '+codegen' in self.spec else 'OFF'),
            '-DgRPC_BUILD_CSHARP_EXT:Bool=OFF',
            '-DgRPC_INSTALL:Bool=ON',
            # Tell grpc to skip vendoring and look for deps via find_package:
            '-DgRPC_CARES_PROVIDER:String=package',
            '-DgRPC_ZLIB_PROVIDER:String=package',
            '-DgRPC_SSL_PROVIDER:String=package',
            '-DgRPC_PROTOBUF_PROVIDER:String=package',
            '-DgRPC_USE_PROTO_LITE:Bool=OFF',
            '-DgRPC_PROTOBUF_PACKAGE_TYPE:String=CONFIG',
        ]
        return args
