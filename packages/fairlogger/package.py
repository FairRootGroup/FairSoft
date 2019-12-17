# Copyright 2019 GSI Helmholtz Centre for Heavy Ion Research
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack import *

class Fairlogger(CMakePackage):
    """Lightweight and fast C++ Logging Library"""

    homepage = "https://github.com/FairRootGroup/FairLogger"
    url = "https://github.com/FairRootGroup/FairLogger/archive/v1.2.0.tar.gz"
    maintainers = ['dennisklein']

    version('1.2.0', '169417786f12411635c670ea3634c880')
    version('1.3.0', '2d0ef2ea75aab5dbd279e74944b4cbabac681990')
    version('1.4.0', '004029900cde3b6e61191f08288a0fa1')
    version('1.5.0', '7cb633a9b740efce2b1281dc27e32144bd149594')
    version('1.6.0', '849ebd128ed2fcaeb806ebf33488189d4557ac7e')

    def patch(self):
        """Spack strips the git repository, but the version is determined
           by querying the git repository. This patches the CMake code to
           not rely on a successful git query for the version info any more."""
        filter_file('(get_git_version\(.*)\)',
                    '\\1 DEFAULT_VERSION %s)' % self.spec.version,
                    'CMakeLists.txt')

    def setup_dependent_build_environment(self, env, dependent_spec):
        """Prepend this package to the CMAKE_PREFIX_PATH"""
        env.prepend_path('CMAKE_PREFIX_PATH', self.prefix)
