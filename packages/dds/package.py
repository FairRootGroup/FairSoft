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
    version('3.0', tag='3.0')
    version('2.5', tag='2.5')
    version('2.2', tag='2.2')
    
    depends_on('boost@1.67.0: cxxstd=11 +container', when='@2.5:')
    depends_on('boost@1.67.0:1.68.0 cxxstd=11 +container +signals', when='@2.2')
    depends_on('cmake@3.11:', type='build')

    patch('correct_version_info_25.patch', level=0, when='@2.5')
    patch('correct_version_info_22.patch', level=0, when='@2.2')

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
