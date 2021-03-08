# Copyright 2013-2021 Lawrence Livermore National Security, LLC and other
#   Spack Project Developers. See the top-level COPYRIGHT file for details.
# Copyright 2020-2021 GSI Helmholtz Centre for Heavy Ion Research GmbH,
#   Darmstadt, Germany
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack import *


class Fairlogger(CMakePackage):
    """Lightweight and fast C++ Logging Library"""

    homepage = 'https://github.com/FairRootGroup/FairLogger'
    git = 'https://github.com/FairRootGroup/FairLogger.git'
    maintainers = ['dennisklein', 'ChristianTackeGSI']
    generator = 'Ninja'

    version('develop', branch='dev', get_full_repo=True)
    version('1.9.1', tag='v1.9.1', commit='340b005997a80f94c2acc7a749e80732b2868a94', no_cache=True)
    version('1.9.0', tag='v1.9.0', commit='bcfe438862edc4047131a282c5e72a77d0b0d78c', no_cache=True)
    version('1.8.0', tag='v1.8.0', commit='56780689fca5560cf3e59d5c156b0adb6d1622f9', no_cache=True)
    version('1.7.0', tag='v1.7.0', commit='8446c6db0cb3ec5b035198da5f066fe431aa5a5b', no_cache=True)
    version('1.6.2', tag='v1.6.2', commit='cdf887f5da7c9871b621a88e9098a78d17da2eb0', no_cache=True)
    version('1.6.1', tag='v1.6.1', commit='86ab87de7b8211395f6c6bffce4efbf988ea5a4f', no_cache=True)
    version('1.6.0', tag='v1.6.0', commit='b9edcd623d758b79bb0d424c02c71239b2cc6b2a', no_cache=True)
    version('1.5.0', tag='v1.5.0', commit='9949e83a141e2678b9d0af6947418ceab21b4e77', no_cache=True)
    version('1.4.0', tag='v1.4.0', commit='aaacaf316ebe15a880a1f94b684919e17bf76844', no_cache=True)
    version('1.3.0', tag='v1.3.0', commit='9a8acdf6ebe47b91c57c88bad878c0ecee83e659', no_cache=True)
    version('1.2.0', tag='v1.2.0', commit='63820e5f2c3bae4af70597c6e4e3ff0b960781ab', no_cache=True)
    version('1.1.0', tag='v1.1.0', commit='de02bd068fcad17fd14f74c48bc60640d387a75e', no_cache=True)
    # TODO Once https://github.com/spack/spack/issues/14344 is resolved, enable
    #      source caching again (by removing the `no_cache` argument).

    variant('build_type', default='RelWithDebInfo',
            values=('Debug', 'Release', 'RelWithDebInfo'),
            multi=False,
            description='CMake build type')
    variant('cxxstd', default='default',
            values=('11', '14', '17'),
            multi=False,
            description='Use the specified C++ standard when building.')
    variant('pretty',
            default=False,
            description='Use BOOST_PRETTY_FUNCTION macro (Supported from 1.4+).')
    conflicts('+pretty', when='@:1.3')

    depends_on('boost', when='+pretty')
    conflicts('^boost@1.70:', when='^cmake@:3.14')
    depends_on('fmt@5.3.0:5.99', when='@1.6.0:1.6.1')
    depends_on('fmt@5.3.0:', when='@1.6.2:')

    depends_on('cmake@3.9.4:', type='build')
    depends_on('git', type='build')
    depends_on('ninja', type='build')

    def cmake_args(self):
        args = []
        args.append('-DDISABLE_COLOR=ON')
        cxxstd = self.spec.variants['cxxstd'].value
        if cxxstd != 'default':
           args.append('-DCMAKE_CXX_STANDARD=%s' % cxxstd)
        if self.spec.satisfies('@1.4:'):
           args.append('-DUSE_BOOST_PRETTY_FUNCTION=%s' %
                       ('ON' if '+pretty' in self.spec else 'OFF'))
        if self.spec.satisfies('@1.6:'):
            args.append('-DUSE_EXTERNAL_FMT=ON')
        if self.spec.satisfies('^boost@:1.69.99'):
            args.append('-DBoost_NO_BOOST_CMAKE=ON')
        return args
