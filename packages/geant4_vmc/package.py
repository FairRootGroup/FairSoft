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


class Geant4Vmc(CMakePackage):
    """Geant4 VMC implements the Virtual Monte Carlo (VMC) for Geant4"""

    # FIXME: Add a proper url for your package's homepage here.
    homepage = "https://github.com/vmc-project/geant4_vmc"
    url = "https://github.com/vmc-project/geant4_vmc/archive/v3-6.tar.gz"

    version('3-6', '01507945dfcc21827628d0eb6b233931')
    version('4-0-p1', 'd7e88a3ef11ea62bec314b5f251c91b1')
    version('5-0', sha256='9a3820ea4b68b5a0697c340bbbc0972b9c8e4205ceecdd87258a9bdfd249cd8b')

    # FIXME: Add dependencies if required.
    depends_on('cmake', type='build')
    depends_on('root')
    depends_on('geant4')
    depends_on('vgm')
    depends_on('vmc', when='@5-0:')

    def cmake_args(self):
        spec = self.spec
        options = []
        options.append('-DGeant4VMC_USE_VGM=ON')
        options.append('-DGeant4VMC_USE_GEANT4_UI=Off')
        options.append('-DGeant4VMC_USE_GEANT4_VIS=Off')
        options.append('-DGeant4VMC_USE_GEANT4_G3TOG4=On')
        options.append('-DROOT_DIR={0}'.format(
                self.spec['root'].prefix))
        options.append('-DGeant4_DIR={0}'.format(
                self.spec['geant4'].prefix))
        options.append('-DCLHEP_DIR={0}'.format(
                self.spec['geant4'].prefix))
        options.append('-DVGM_DIR={0}'.format(
                self.spec['vgm'].prefix))
        options.append('-DWITH_TEST=OFF')

        return options
