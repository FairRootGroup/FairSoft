# Copyright 2013-2021 Lawrence Livermore National Security, LLC and other
#   Spack Project Developers. See the top-level COPYRIGHT file for details.
# Copyright 2019-2021 GSI Helmholtz Centre for Heavy Ion Research GmbH,
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

    version('428-alice1', '8751dda1c4b5f137817876ea0d4b8a5b')

    patch('add_missing_extern_keyword.patch')

    def cmake_args(self):
        args=[]
        args.append('-DCMAKE_MACOSX_RPATH=ON')
        return args
