# Copyright 2013-2022 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)


class Faircmakemodules(CMakePackage):
    """CMake Modules for FAIR Software"""

    homepage = "https://github.com/FairRootGroup/FairCMakeModules"
    url      = "https://github.com/FairRootGroup/FairCMakeModules/archive/v0.1.0.tar.gz"
    git      = "https://github.com/FairRootGroup/FairCMakeModules"

    maintainers = ['dennisklein', 'ChristianTackeGSI']

    version('master', branch='main')
    version('1.0.0', sha256='ec60c31f38050c1173d512c58c684650db66736877c580936f7ecca33eeaf696')
    version('0.2.0', sha256='a1f8e1e022eabbc7729ff6055915a3d9c419c4f5ee7301f63df4e04c42be2edd')
    version('0.1.0', sha256='1a2be01d3f3e0d0a5bbaf0ed4a4ea8d2c2f86eeeda3158f760761b41bd568e02')

    depends_on('cmake@3.16:')
