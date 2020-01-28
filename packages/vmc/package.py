# Copyright 2013-2019 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

# ----------------------------------------------------------------------------
# If you submit this package back to Spack as a pull request,
# please first remove this boilerplate and all FIXME comments.
#
# This is a template package file for Spack.  We've put "FIXME"
# next to all the things you'll want to change. Once you've handled
# them, you can save this file and test your package like this:
#
#     spack install vmc
#
# You can edit this file again by typing:
#
#     spack edit vmc
#
# See the Spack documentation for more information on packaging.
# ----------------------------------------------------------------------------

from spack import *


class Vmc(CMakePackage):
    # The Virtual Monte Carlo core library.

    homepage = "https://github.com/vmc-project/vmc"
    url      = "https://github.com/vmc-project/vmc/archive/v0-1.tar.gz"

    version('1-0', sha256='3da58518b32db1b503082e3205884802a1a263a915071b96e3fd67861db3ca40')

    depends_on('root')
