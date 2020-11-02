# Copyright 2013-2020 Lawrence Livermore National Security, LLC and other
#   Spack Project Developers. See the top-level COPYRIGHT file for details.
# Copyright 2019-2020 GSI Helmholtz Centre for Heavy Ion Research GmbH,
#   Darmstadt, Germany
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack import *


class Fairmq(CMakePackage):
    """C++ Message Queuing Library and Framework"""

    homepage = 'https://github.com/FairRootGroup/FairMQ'
    git = 'https://github.com/FairRootGroup/FairMQ.git'
    maintainers = ['dennisklein', 'ChristianTackeGSI']
    generator = 'Ninja'

    version('develop', branch='dev', submodules=True, get_full_repo=True)
    version('1.4.26', tag='v1.4.26', commit='49d8a1b4dda2c2d446b73a1e39303b581f06f048', submodules=True, no_cache=True)
    version('1.4.25', tag='v1.4.25', commit='1b30f3ac142165b5d17d8ac3ec616414946e23bf', submodules=True, no_cache=True)
    version('1.4.24', tag='v1.4.24', commit='35c7959c530c010da718892fd3948467f104d267', submodules=True, no_cache=True)
    version('1.4.23', tag='v1.4.23', commit='5e97d8595659edeb87ea6aa47a64340e3c9f2ed8', submodules=True, no_cache=True)
    version('1.4.22', tag='v1.4.22', commit='690e8a037098ed4b7097f687d853d20a2b8cc028', submodules=True, no_cache=True)
    version('1.4.21', tag='v1.4.21', commit='3eca8e9defd7e3b10f7b1ab02c2e45ec68911092', submodules=True, no_cache=True)
    version('1.4.20', tag='v1.4.20', commit='78b1c188bfb6158a7c1a8db2745a88099dff19da', submodules=True, no_cache=True)
    version('1.4.19', tag='v1.4.19', commit='c60dd9965c02011684994ac4a698c8d644a56ac1', submodules=True, no_cache=True)
    version('1.4.18', tag='v1.4.18', commit='b5bb476b0da55bfd5b0b72f3da52afac194b865b', submodules=True, no_cache=True)
    version('1.4.17', tag='v1.4.17', commit='53a4d17f8b498a056199ce4b665dbeed847be6b2', submodules=True, no_cache=True)
    version('1.4.16', tag='v1.4.16', commit='8cfc04721eeeade40723497cf5e6d26683804797', submodules=True, no_cache=True)
    version('1.4.15', tag='v1.4.15', commit='4218c185a4018c36a5fbc32d7c845b1dc811a567', submodules=True, no_cache=True)
    version('1.4.14', tag='v1.4.14', commit='960b612d802e755d75f902e55b42e32f0e0e1e53', submodules=True, no_cache=True)
    version('1.4.13', tag='v1.4.13', commit='38eb9d22e4abe1c3c918aa457c1ac7abfeac5762', submodules=True, no_cache=True)
    version('1.4.12', tag='v1.4.12', commit='9f8a3553ba7e6c3ce5c9e378d77d3e16d7ce6daf', submodules=True, no_cache=True)
    version('1.4.11', tag='v1.4.11', commit='e6dede492e02d6966cfa68e6820f90f679b74592', submodules=True, no_cache=True)
    version('1.4.10', tag='v1.4.10', commit='f31be6d7a10ab0b7e4183576438268c8122117a5', submodules=True, no_cache=True)
    version('1.4.9', tag='v1.4.9', commit='f6e3183f453d3daf97e529d3b834da715b43c47b', submodules=True, no_cache=True)
    version('1.4.8', tag='v1.4.8', commit='3f5374820a56c472a79e81b977861eddf4bff343', no_cache=True)
    version('1.4.7', tag='v1.4.7', commit='7cacf471b957aa1a89616b84339ce0b25699c7a0', no_cache=True)
    version('1.4.6', tag='v1.4.6', commit='93eb599df7d9ee4c869e2fe70c03b7a845739683', no_cache=True)
    version('1.4.5', tag='v1.4.5', commit='b1c82641237c1da7ae4d7af1fcb1cf69f596a54c', no_cache=True)
    version('1.4.4', tag='v1.4.4', commit='99c8d33191a8f69bcd6b51cfa8c11a1d736734b0', no_cache=True)
    version('1.4.3', tag='v1.4.3', commit='3582091b1c76cbe689b8e66813ea71dd5ff55bc5', no_cache=True)
    version('1.4.2', tag='v1.4.2', commit='2457094b6c4004a75620a45329574d983cdc263e', no_cache=True)
    version('1.4.1', tag='v1.4.1', commit='95ec56dcf0d95917a0c9cdecd1004d4a1c4aa479', no_cache=True)
    version('1.4.0', tag='v1.4.0', commit='4c2785dfc1d98576917bc3cfb2a01eab675c5f6e', no_cache=True)
    version('1.3.9', tag='v1.3.9', commit='d91a7d23616d2781938423b2362651185e2c0607', no_cache=True)
    # TODO Once https://github.com/spack/spack/issues/14344 is resolved, enable
    #      source caching again (by removing the `no_cache` argument).

    variant('build_type', default='RelWithDebInfo',
            values=('Debug', 'Release', 'RelWithDebInfo'),
            multi=False,
            description='CMake build type')
    variant('cxxstd', default='default',
            values=('11', '14', '17'),
            multi=False,
            description='Force the specified C++ standard when building.')
    conflicts('cxxstd=11', when='@1.4.11:')

    patch('fix_find_dds.patch', when='@1.4.0:1.4.4')
    patch('use_bundled_gtest_149.patch', when='@1.4.9:1.4.16')
    patch('missing_stdexcept_header.patch', when='@:1.4.19')
    patch('fix_cpp17moveinsertable_assertion_xcode12.patch', when='@1.4.8:1.4.23')
    patch('update_command_format_in_pmix_plugin.patch', when='@1.4.23')

    depends_on('googletest@1.7:', when='@:1.4.8')
    depends_on('boost@1.64: +container+program_options+thread+system+filesystem+regex+date_time', when='@1.3')
    depends_on('boost@1.64: +container+program_options+filesystem+date_time+regex', when='@1.4:')
    conflicts('^boost@1.70:', when='^cmake@:3.14')
    depends_on('fairlogger@1.2:1.5', when='@:1.4.7')
    depends_on('fairlogger@1.2:', when='@1.4.8:1.4.10')
    depends_on('fairlogger@1.4:', when='@1.4.11:')
    depends_on('fairlogger@1.6:', when='@develop')
    if Version(spack_version) >= Version('0.14'):
        depends_on('libzmq@4.1.5:')
    else:
        depends_on('zeromq@4.1.5:')
    depends_on('nanomsg@1.1.5:', when='@:1.4.16')
    depends_on('msgpack-c@3.1:', when='@:1.4.16')
    depends_on('dds@2.4', when='@:1.4.9')
    depends_on('dds@2.5-odc', when='@1.4.10')
    depends_on('dds@3.0:', when='@1.4.11:')
    depends_on('flatbuffers', when='@1.4.9:')
    depends_on('pmix@2.1.4:', when='@1.4:')

    depends_on('cmake@3.9.4:', type='build', when='@1.3')
    depends_on('cmake@3.10:', type='build', when='@1.4.0:1.4.7')
    depends_on('cmake@3.11:', type='build', when='@1.4.8:1.4.12')
    depends_on('cmake@3.12:', type='build', when='@1.4.13:,develop')
    depends_on('git', type='build')
    depends_on('ninja', type='build')

    def cmake_args(self):
        args = []
        args.append('-DDISABLE_COLOR=ON')
        args.append('-DBUILD_NANOMSG_TRANSPORT=ON')
        args.append('-DBUILD_DDS_PLUGIN=ON')
        cxxstd = self.spec.variants['cxxstd'].value
        if cxxstd != 'default':
           args.append('-DCMAKE_CXX_STANDARD={0}'.format(cxxstd))
        if self.spec.satisfies('@1.4:'):
           args.append('-DBUILD_PMIX_PLUGIN=ON')
        if self.spec.satisfies('@1.4.9:'):
           args.append('-DBUILD_SDK_COMMANDS=ON')
        if self.spec.satisfies('@1.4.11:'):
           args.append('-DBUILD_SDK=ON')
        # NOTE Support for building the ofi transport will be added at a later
        #      point in time.
        # args.append('-DBUILD_OFI_TRANSPORT=ON')
        if self.spec.satisfies('^boost@:1.69.99'):
            args.append('-DBoost_NO_BOOST_CMAKE=ON')
        return args
