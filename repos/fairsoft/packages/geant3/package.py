# Copyright 2013-2021 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack import *


class Geant3(CMakePackage):
    """Simulation software using Monte Carlo methods to describe how particles pass through matter.."""

    homepage = "https://root.cern.ch/vmc"
    url      = 'https://github.com/FairRootGroup/geant3/archive/v3-7_fairsoft.tar.gz'
    git      = "https://github.com/FairRootGroup/geant3.git"

    version('3.7', sha256='739548b5c38133d6b3e0f4e5b3b2a762ffd49eb829f635878d0b017c2e309aa9')
    version('3.0', sha256='45bbd3a13a16d50f39c9bb7774c7820f8ea5f977fdae77f860b0b641296ca691')
    version('2.7', sha256='2a0e0c65dcf62984b87b8a1700ee7da4fc6dfb9829ca3e43fc7373600aeab2c4')

    variant('build_type', default='Nightly',
            description='CMake build type',
            values=('Nightly'))
    variant('cxxstd', default='default',
            values=('11', '14', '17'),
            multi=False,
            description='Force the specified C++ standard when building.')

    depends_on('root')
    depends_on('vmc', when='@3:')

    patch('gcalor_stringsize.patch', level=0, when='@:3.6')
    patch('dict_fixes_30.patch', when='@3.0')
    patch('gfortran10_support.patch', when='@:3.6')
    patch('fix_geane_propagator_v2-7_fairsoft.patch', when="@2.7")
    patch('fix_geane_propagator_v3-0_fairsoft.patch', when="@3.0")
    patch('fix_gfortran_7.patch', when='%gcc@7') # see https://github.com/alisw/alidist/issues/1345

    def url_for_version(self, version):
        version_str = version.up_to(2).dashed
        url = 'https://github.com/FairRootGroup/geant3/archive/v{0}_fairsoft.tar.gz'
        return url.format(version_str)

    def cmake_args(self):
        options = []
        cxxstd = self.spec.variants['cxxstd'].value
        if cxxstd == 'default' and self.spec.satisfies('@:2.7'):
            # geant3 2.7 needs an explicit CXX setting on macOS 11
            cxxstd = '11'
        if cxxstd != 'default':
            options.append(self.define('CMAKE_CXX_STANDARD', cxxstd))
        options.append('-DCMAKE_INSTALL_LIBDIR:PATH=lib')
        options.append('-DROOT_DIR={0}'.format(
                self.spec['root'].prefix))
        if self.spec.satisfies('@3.7:'):
            options.append('-DBUILD_GCALOR=ON')

        return options

    def common_env_setup(self, env):
        env.set('G3SYS', join_path(self.prefix.share, 'geant3'))
        # So that root finds the shared library / rootmap
        env.prepend_path("LD_LIBRARY_PATH", self.prefix.lib)

    def setup_run_environment(self, env):
        self.common_env_setup(env)

    def setup_dependent_build_environment(self, env, dependent_spec):
        self.common_env_setup(env)

    def setup_dependent_run_environment(self, env, dependent_spec):
        self.common_env_setup(env)
