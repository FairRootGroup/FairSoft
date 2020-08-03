# Copyright 2013-2019 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack import *


class PerlDatemanip(PerlPackage):
    """The parser contained here will only parse absolute dates, if you want a
    date parser that can parse relative dates then take a look at the Time
    modules by David Muir on CPAN."""

    homepage = "https://metacpan.org/release/DateManip"
    url      = "https://cpan.metacpan.org/authors/id/S/SB/SBECK/Date-Manip-6.82.tar.gz"

    version('6.82', sha256='fa96bcf94c6b4b7d3333f073f5d0faad59f546e5aec13ac01718f2e6ef14672a')
