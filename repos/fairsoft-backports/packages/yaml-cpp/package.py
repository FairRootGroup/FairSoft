# Copyright 2013-2020 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack.spec import ConflictsInSpecError


yaml_cpp_tests_libcxx_error_msg = 'yaml-cpp tests incompatible with libc++'


class YamlCpp(CMakePackage):
    """A YAML parser and emitter in C++"""

    homepage = "https://github.com/jbeder/yaml-cpp"
    url      = "https://github.com/jbeder/yaml-cpp/archive/yaml-cpp-0.5.3.tar.gz"
    git      = "https://github.com/jbeder/yaml-cpp.git"

    version('develop', branch='master')
    version('0.6.3', sha256='77ea1b90b3718aa0c324207cb29418f5bced2354c2e483a9523d98c3460af1ed')
    version('0.6.2', sha256='e4d8560e163c3d875fd5d9e5542b5fd5bec810febdcba61481fe5fc4e6b1fd05')
    version('0.5.3', sha256='decc5beabb86e8ed9ebeb04358d5363a5c4f72d458b2c788cb2f3ac9c19467b2')
    version('0.3.0', sha256='ab8d0e07aa14f10224ed6682065569761f363ec44bc36fcdb2946f6d38fe5a89')

    variant('shared', default=True,
            description='Build shared instead of static libraries')
    variant('pic',   default=True,
            description='Build with position independent code')
    variant('tests', default=False,
            description='Build yaml-cpp tests using internal gtest')

    depends_on('boost@:1.66.99', when='@0.5.0:0.5.3')

    conflicts('%gcc@:4.7', when='@0.6.0:', msg="versions 0.6.0: require c++11 support")
    conflicts('%clang@:3.3.0', when='@0.6.0:', msg="versions 0.6.0: require c++11 support")
    conflicts('%apple-clang@:4.0.0', when='@0.6.0:', msg="versions 0.6.0: require c++11 support")
    conflicts('%intel@:11.1', when='@0.6.0:', msg="versions 0.6.0: require c++11 support")
    conflicts('%xl@:13.1', when='@0.6.0:', msg="versions 0.6.0: require c++11 support")
    conflicts('%xl_r@:13.1', when='@0.6.0:', msg="versions 0.6.0: require c++11 support")
    conflicts('%clang cxxflags="-stdlib=libc++"', when='+tests',
              msg=yaml_cpp_tests_libcxx_error_msg)

    def flag_handler(self, name, flags):
        # We cannot catch all conflicts with the conflicts directive because
        # the user can add arbitrary strings to the flags. Here we can at least
        # fail early.
        # We'll include cppflags in case users mistakenly put c++ flags there.
        spec = self.spec
        if name in ('cxxflags', 'cppflags') and spec.satisfies('+tests'):
            if '-stdlib=libc++' in flags:
                raise ConflictsInSpecError(
                    spec,
                    [(spec,
                      spec.compiler_flags[name],
                      spec.variants['tests'],
                      yaml_cpp_tests_libcxx_error_msg)]
                )
        return (flags, None, None)

    def cmake_args(self):
        options = []

        options.extend([
            self.define_from_variant('BUILD_SHARED_LIBS', 'shared'),
            self.define_from_variant('YAML_BUILD_SHARED_LIBS', 'shared'),
            self.define_from_variant('CMAKE_POSITION_INDEPENDENT_CODE', 'pic'),
            self.define_from_variant('YAML_CPP_BUILD_TESTS', 'tests'),
        ])

        return options

    def url_for_version(self, version):
        url = "https://github.com/jbeder/yaml-cpp/archive/{0}-{1}.tar.gz"
        if version < Version('0.5.3'):
            return url.format('release', version)
        else:
            return url.format('yaml-cpp', version)
