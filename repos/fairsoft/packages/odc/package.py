# Copyright 2013-2021 Lawrence Livermore National Security, LLC and other
#   Spack Project Developers. See the top-level COPYRIGHT file for details.
# Copyright 2020-2021 GSI Helmholtz Centre for Heavy Ion Research GmbH,
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
    version('0.18', tag='0.18', commit='02be2c613f7e794cac9fbbdb0af22e9dc5b59f4d', no_cache=True)
    version('0.16', tag='0.16', commit='b3adfb2343e182be4507097a58f21f998a551e52', no_cache=True)
    version('0.10', tag='0.10', commit='776855e3946c290b88e40060b032095e60f1fef3', no_cache=True)

    # See: https://github.com/FairRootGroup/ODC/commit/1618b38c12c9114268c9bce550e9e01e7015a040
    patch('fix_protoc_args.patch', when='@:0.12')

    depends_on('boost@1.67: +log+thread+program_options+filesystem+system+regex')
    conflicts('^boost@1.70:', when='^cmake@:3.14')
    depends_on('protobuf +shared')
    depends_on('grpc +codegen+shared')
    depends_on('dds@3.5.3:')
    depends_on('fairmq@1.4.26:')
    depends_on('fairlogger')

    depends_on('cmake@3.12:', type='build')
    depends_on('git', type='build')
    depends_on('ninja', type='build')

    def cmake_args(self):
        args = []
        if self.spec.satisfies('^boost@:1.69.99'):
            args.append('-DBoost_NO_BOOST_CMAKE=ON')
        return args
