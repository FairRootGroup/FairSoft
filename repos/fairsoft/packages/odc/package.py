# Copyright 2013-2020 Lawrence Livermore National Security, LLC and other
#   Spack Project Developers. See the top-level COPYRIGHT file for details.
# Copyright 2020 GSI Helmholtz Centre for Heavy Ion Research GmbH,
#   Darmstadt, Germany
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack import *


class Odc(CMakePackage):
    """Online Device Control (ODC).
       The Online Device Control project control/communicate with a graph (topology) of FairMQ devices using DDS or PMIx."""

    homepage = "https://github.com/FairRootGroup/ODC"
    git = "https://github.com/FairRootGroup/ODC.git"
    generator = 'Ninja'

    version('develop', branch='master', get_full_repo=True)
    version('0.8', tag='0.8', commit='d53a1a4253db17fd52d3904f6b2a5da5904c0d8a')

    depends_on('boost@1.67: +log+thread+program_options+filesystem+system+regex')
    conflicts('^boost@1.70:', when='^cmake@:3.14')
    depends_on('protobuf +shared')
    depends_on('grpc +codegen+shared')
    depends_on('dds@3.5.1:')
    depends_on('fairmq@1.4.21:')
    depends_on('fairlogger')

    depends_on('cmake@3.12:', type='build')
    depends_on('git', type='build')
    depends_on('ninja', type='build')

    def cmake_args(self):
        args = []
        if self.spec.satisfies('^boost@:1.69.99'):
            args.append('-DBoost_NO_BOOST_CMAKE=ON')
        return args
