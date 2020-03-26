# Copyright 2013-2020 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack import *


class Vgm(CMakePackage):
    """Geometry conversion tool, actually providing conversion between Geant4 and ROOT TGeo geometry models."""

    homepage = "https://github.com/vmc-project/vgm"
    url = "https://github.com/vmc-project/vgm/archive/v4-5.tar.gz"

    version('4-7', sha256='a5f5588db457dc3e6562d1f7da1707960304560fbb0a261559fa3f112a476aea')
    version('4-6', sha256='6bf0aeef38f357a313e376090b45d3e0713ef9e52ca198075fae8579b8d5a23a')
    version('4-5', sha256='dc61c6214fdf592dfaa3766eed83cf2bbeabb1755f5146a6d3bcfe55ddbe428f')
    version('4-4', sha256='a915ff3500daa99b74ce9039fbd8abcbd08051e838a1b337e1d794b73537b33b')

    depends_on("root")
    depends_on("geant4")

    def cmake_args(self):
        spec = self.spec
        options = []
        options.append('-DROOT_DIR={0}'.format(
                self.spec['root'].prefix))
        options.append('-DGeant4_DIR={0}'.format(
                self.spec['geant4'].prefix))
        if '~clhep' in spec['geant4']:
            options.append('-DCLHEP_DIR={0}'.format(
                    self.spec['geant4'].prefix))
        else:
            options.append('-DCLHEP_DIR={0}'.format(
                    self.spec['clhep'].prefix))
        options.append('-DWITH_TEST=OFF')

        return options
