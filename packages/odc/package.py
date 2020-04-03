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

    depends_on('boost@1.67: +log+thread+program_options+filesystem+system+regex')
    conflicts('^boost@1.70:', when='^cmake@:3.14')
    depends_on('protobuf +shared')
    depends_on('grpc +codegen+shared')
    depends_on('dds@develop')
    depends_on('fairmq@develop')
    depends_on('fairlogger@:1.5') # TODO Remove version restriction once ODC
                                  # supports FairLogger 1.6+ (can handle the
                                  # transitive fmt dependency)

    depends_on('cmake@3.12:', type='build')
    depends_on('git', type='build')
    depends_on('ninja', type='build')
