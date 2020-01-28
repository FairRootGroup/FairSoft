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

    git      = "https://github.com/FairRootGroup/geant3.git"

    version('v2-5-gcc8', tag='v2-5-gcc8')
    version('v2-7_fairsoft', tag='v2-7_fairsoft')
    version('v3-0_fairsoft', tag='v3-0_fairsoft')

    # FIXME: Add dependencies if required.
    depends_on('cmake', type='build')
    depends_on('root')
    depends_on('vmc', when='@v3-0_fairsoft:')

    def cmake_args(self):
        spec = self.spec
        options = []
        options.append('-DROOT_DIR={0}'.format(
                self.spec['root'].prefix))

        return options

    def setup_environment(self, spack_env, run_env):
        run_env.set('G3SYS', '%s/share/geant3' % self.spec.prefix)
