# Copyright 2013-2022 Lawrence Livermore National Security, LLC and other
#   Spack Project Developers. See the top-level COPYRIGHT file for details.
# Copyright 2019-2022 GSI Helmholtz Centre for Heavy Ion Research GmbH,
#   Darmstadt, Germany
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack import *


class Pythia6(CMakePackage):
    """The Pythia6 program can be used to generate high-energy-physics "events",
       i.e. sets of outgoing particles produced in the interactions between two
       in-coming particles."""

    homepage = "https://pythia6.hepforge.org/"
    url      = "https://github.com/alisw/pythia6/archive/428-alice1.tar.gz"

    version('428-alice1', sha256='b14e82870d3aa33d6fa07f4b1f4d17f1ab80a37d753f91ca6322352b397cb244')

    patch('add_missing_extern_keyword.patch')

    def cmake_args(self):
        args=[]
        args.append('-DCMAKE_MACOSX_RPATH=ON')
        return args
