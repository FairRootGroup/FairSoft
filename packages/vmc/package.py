# Copyright 2013-2020 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack import *


class Vmc(CMakePackage):
    """The Virtual Monte Carlo core library"""

    homepage = "https://github.com/vmc-project/vmc"
    url      = "https://github.com/vmc-project/vmc/archive/v1-0.tar.gz"

    version('1-0-p1', sha256='4a20515f7de426797955cec4a271958b07afbaa330770eeefb5805c882ad9749')
    version('1-0', sha256='3da58518b32db1b503082e3205884802a1a263a915071b96e3fd67861db3ca40')

    depends_on('root@6.18.04:')
