# Copyright 2013-2020 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)


class Hepmc(CMakePackage):
    """The HepMC package is an object oriented, C++ event record for
       High Energy Physics Monte Carlo generators and simulation."""

    homepage = "https://hepmc.web.cern.ch/hepmc/"
    url      = "https://hepmc.web.cern.ch/hepmc/releases/hepmc2.06.11.tgz"

    tags = ['hep']

    version('2.06.11', sha256='86b66ea0278f803cde5774de8bd187dd42c870367f1cbf6cdaec8dc7cf6afc10')
    version('2.06.10', sha256='5adedd9e3f7447e1e5fc01b72f745ab87da2c1611df89208bb3d7c6ea94c11a4')
    version('2.06.09', '52518437a64f6b4284e9acc2ecad6212')
    version('2.06.08', 'a2e889114cafc4f60742029d69abd907')
    version('2.06.07', '11d7035dccb0650b331f51520c6172e7')
    version('2.06.06', '102e5503537a3ecd6ea6f466aa5bc4ae')
    version('2.06.05', '2a4a2a945adf26474b8bdccf4f881d9c')

    variant('length', default='CM', values=('CM', 'MM'), multi=False,
            description='Unit of length')
    variant('momentum', default='GEV', values=('GEV', 'MEV'), multi=False,
            description='Unit of momentum')

    depends_on('cmake@2.8.9:', type='build')

    def cmake_args(self):
        return [
            self.define_from_variant('momentum'),
            self.define_from_variant('length')
        ]

    def url_for_version(self, version):
        if version <= Version("2.06.08"):
            url = "http://lcgapp.cern.ch/project/simu/HepMC/download/HepMC-{0}.tar.gz"
        else:
            url = "https://hepmc.web.cern.ch/hepmc/releases/hepmc{0}.tgz"
        return url.format(version)
