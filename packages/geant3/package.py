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
#     spack install geant3
#
# You can edit this file again by typing:
#
#     spack edit geant3
#
# See the Spack documentation for more information on packaging.
# ----------------------------------------------------------------------------

from spack import *


class Geant3(CMakePackage):
    """Simulation software using Monte Carlo methods to describe how particles pass through matter.."""

    # FIXME: Add a proper url for your package's homepage here.
    homepage = "https://root.cern.ch/vmc"

    git      = "https://github.com/vmc-project/geant3"

    version('2.7', tag='v2-7')
    version('2.6', tag='v2-6')
    version('2.5', tag='v2-5')
    version('2.4', tag='v2-4')
    version('2.3', tag='v2-3')
    version('2.2', tag='v2-2')
    version('2.1', tag='v2-1')
    version('2.0', tag='v2-0')

    # FIXME: Add dependencies if required.
    #depends_on("root")

    def install(self, spec, prefix):
        make()
        make('install')
