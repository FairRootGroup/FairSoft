# Copyright 2013-2022 Lawrence Livermore National Security, LLC and other
#   Spack Project Developers. See the top-level COPYRIGHT file for details.
# Copyright 2020-2022 GSI Helmholtz Centre for Heavy Ion Research GmbH,
#   Darmstadt, Germany
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack import *


class FairsoftConfig(CMakePackage):
    """Legacy fairsoft-config script"""

    homepage = 'https://github.com/FairRootGroup/fairsoft-config'
    git = 'https://github.com/FairRootGroup/fairsoft-config'
    maintainers = ['dennisklein', 'ChristianTackeGSI']

    version('develop')
    version('apr21')
    version('nov20')
    version('jun19')

    variant('cxxstd',
            default='11',
            values=('11', '14', '17'),
            multi=False,
            description='C++ standard reported')

    depends_on('cmake@3:', type='build')
    depends_on('root', type=('build', 'link', 'run'))

    def cmake_args(self):
        args = []
        args.append('-DFAIRSOFT_VERSION=%s' % self.version)
        args.append('-DCMAKE_CXX_STANDARD=%s' %
                    self.spec.variants['cxxstd'].value)
        return args
