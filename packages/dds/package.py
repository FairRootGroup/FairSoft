# Copyright 2013-2019 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack import *


class Dds(CMakePackage):
    """The Dynamic Deployment System (DDS)
       A tool-set that automates and significantly simplifies a deployment of user defined processes and their dependencies on any resource management system using a given topology. """

    homepage = "http://dds.gsi.de"
    git      = "https://github.com/FairRootGroup/DDS"

    version('2.5', tag='2.5')
    version('2.2', tag='2.2')
    version('2.1-1-g181b66a', commit='181b66aca6072601d466436826fa5dac7a77ddc0')

    version('master', branch = 'master')

    depends_on('boost@1.68.0: cxxstd=11 +container', when='@master')
    depends_on('boost@1.68.0: cxxstd=11 +container', when='@2.5')
    depends_on('boost@1.68.0: cxxstd=11 +container', when='@2.2')
    depends_on('cmake@3.1.3:' , type='build')

    build_targets = ['all', 'wn_bin']

    patch('correct_version_info_2546.patch', level=0, when='@master')
    patch('correct_version_info_25.patch', level=0, when='@2.5')
    patch('correct_version_info_22.patch', level=0, when='@2.2')
    patch('correct_version_info_211.patch', level=0, when='@2.1-1-g181b66a')

    def cmake_args(self):
        spec = self.spec
        options = []
        options.append('-DBoost_NO_BOOST_CMAKE=ON')
        options.append('-DBOOST_ROOT={0}'.format(
                self.spec['boost'].prefix))

        return options
