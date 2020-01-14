# Copyright 2013-2019 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

import os.path
import shutil

from spack import *


class Dds(CMakePackage):
    """The Dynamic Deployment System (DDS)
       A tool-set that automates and significantly simplifies a deployment of user defined processes and their dependencies on any resource management system using a given topology. """

    homepage = "http://dds.gsi.de"
    url      = "https://github.com/FairRootGroup/DDS/archive/3.0.tar.gz"
    git      = "https://github.com/FairRootGroup/DDS"

    version('master', branch='master')
    version('3.0', sha256='6b6bdbdeb2d43ca2917400e1503e1f5690fd9efb8b18358bd1052ee31ae6974a')
    version('2.5', tag='2.5')
    version('2.2', tag='2.2')
    version('2.1-1-g181b66a', commit='181b66aca6072601d466436826fa5dac7a77ddc0')

    depends_on('boost@1.68.0: cxxstd=11 +container', when='@2.2:')
    depends_on('cmake@3.1.3:', type='build')

    patch('correct_version_info_25.patch', level=0, when='@2.5')
    patch('correct_version_info_22.patch', level=0, when='@2.2')
    patch('correct_version_info_211.patch', level=0, when='@2.1-1-g181b66a')

    def patch(self):
        # Fetching version from .git doesn't work reliebly.
        if os.path.exists(join_path(self.stage.source_path, ".git")):
            shutil.rmtree(join_path(self.stage.source_path, ".git"))

        if self.spec.satisfies("@master"):
            version = "master"
        else:
            version = str(self.spec.version)

        for directory in (self.stage.source_path, self.build_directory):
            with working_dir(directory, create=True):
                with open("version", "w") as f:
                    f.write(version + "\n")

    def cmake_args(self):
        options = []
        options.append('-DBoost_NO_BOOST_CMAKE=ON')
        options.append('-DBOOST_ROOT={0}'.format(
                self.spec['boost'].prefix))

        return options
