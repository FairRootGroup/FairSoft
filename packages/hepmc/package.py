# Copyright 2013-2020 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)


from spack import *


class Hepmc(CMakePackage):
    """The HepMC package is an object oriented, C++ event record for
       High Energy Physics Monte Carlo generators and simulation."""

    homepage = "http://hepmc.web.cern.ch/hepmc/"
    url      = "http://hepmc.web.cern.ch/hepmc/releases/hepmc2.06.09.tgz"

    version('3.2.0', sha256='f132387763d170f25a7cc9f0bd586b83373c09acf0c3daa5504063ba460f89fc')
    version('3.1.2', sha256='4133074b3928252877982f3d4b4c6c750bb7a324eb6c7bb2afc6fa256da3ecc7')
    version('3.1.1', sha256='2fcbc9964d6f9f7776289d65f9c73033f85c15bf5f0df00c429a6a1d8b8248bb')
    version('3.1.0', sha256='cd37eed619d58369041018b8627274ad790020a4714b54ac05ad1ebc1a6e7f8a')
    version('3.0.0',   '2212a5e8d693fbf726c28b43ebc6377a')
    version('2.06.10', sha256='5adedd9e3f7447e1e5fc01b72f745ab87da2c1611df89208bb3d7c6ea94c11a4')
    version('2.06.09', '52518437a64f6b4284e9acc2ecad6212')
    version('2.06.08', 'a2e889114cafc4f60742029d69abd907')
    version('2.06.07', '11d7035dccb0650b331f51520c6172e7')
    version('2.06.06', '102e5503537a3ecd6ea6f466aa5bc4ae')
    version('2.06.05', '2a4a2a945adf26474b8bdccf4f881d9c')

    variant(
        'length', default='CM', description='Unit of length',
        values=('CM', 'MM'), multi=False
    )
    variant(
        'momentum', default='GEV', description='Unit of momentum',
        values=('GEV', 'MEV'), multi=False
    )

    depends_on('cmake@2.8.9:', type='build')

    def cmake_args(self):
        options = []

        if self.spec.variants['length'].value == 'CM':
             options.append('-Dlength:STRING=CM')
        if self.spec.variants['length'].value == 'MM':
             options.append('-Dlength:STRING=MM')
        if self.spec.variants['momentum'].value == 'GEV':
             options.append('-Dmomentum:STRING=GEV')
        if self.spec.variants['momentum'].value == 'MEV':
             options.append('-Dmomentum:STRING=MEV')

        return options


    def url_for_version(self, version):
        if version > Version("3.0.0"):
            url = "http://hepmc.web.cern.ch/hepmc/releases/HepMC3-{0}.tar.gz"
        elif version <= Version("2.06.08"):
            url = "http://lcgapp.cern.ch/project/simu/HepMC/download/HepMC-{0}.tar.gz"
        else:
            url = "http://hepmc.web.cern.ch/hepmc/releases/hepmc{0}.tgz"
        return url.format(version)
