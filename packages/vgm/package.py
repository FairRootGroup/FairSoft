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


class Vgm(CMakePackage):
    """Geometry conversion tool, actually providing conversion between Geant4 and ROOT TGeo geometry models."""

    # FIXME: Add a proper url for your package's homepage here.
    homepage = "https://github.com/vmc-project/vgm"
    url = "https://github.com/vmc-project/vgm/archive/v4-4.tar.gz"

    version('4-4', '42fcd9092981120be1aeb6e3872fa1f7')
    version('4-5', '42fcd9092981120be1aeb6e3872fa1f7')

    # FIXME: Add dependencies if required.
    depends_on('cmake', type='build')
    depends_on("root")
    depends_on("geant4")

    def cmake_args(self):
        spec = self.spec
        options = []
        options.append('-DROOT_DIR={0}'.format(
                self.spec['root'].prefix))
        options.append('-DGeant4_DIR={0}'.format(
                self.spec['geant4'].prefix))
        options.append('-DCLHEP_DIR={0}'.format(
                self.spec['clhep'].prefix))
        options.append('-DWITH_TEST=OFF')
                
        return options
