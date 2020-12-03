# Copyright 2013-2020 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack import *


class Geant3(CMakePackage):
    """Simulation software using Monte Carlo methods to describe how particles pass through matter.."""

    homepage = "https://root.cern.ch/vmc"
    git      = "https://github.com/FairRootGroup/geant3.git"

    version('3.7', tag='v3-7_fairsoft', commit='12092fb6d0ab5249699c8fd2d3af409ac878f262')
    version('3.0', tag='v3-0_fairsoft', commit='be5ef650befe0927a9f762b98f4ea5dfb4af0624')
    version('2.7', tag='v2-7_fairsoft', commit='f4eb0984938c5a0e8795324bac495d319cf0397e')

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
