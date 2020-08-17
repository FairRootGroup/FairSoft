# Copyright 2013-2019 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack import *
import glob
import inspect
import platform


class IntelTbb(Package):
    """Widely used C++ template library for task parallelism.
    Intel Threading Building Blocks (Intel TBB) lets you easily write parallel
    C++ programs that take full advantage of multicore performance, that are
    portable and composable, and that have future-proof scalability.
    """
    homepage = "http://www.threadingbuildingblocks.org/"

    # See url_for_version() below.
    version('2019.4', sha256='673e540aba6e526b220cbeacc3e4ff7b19a8689a00d7a09a9dc94396d73b24df')
    version('2019.3', sha256='b2244147bc8159cdd8f06a38afeb42f3237d3fc822555499d7ccfbd4b86f8ece')
    version('2019.2', sha256='1245aa394a92099e23ce2f60cdd50c90eb3ddcd61d86cae010ef2f1de61f32d9')
    version('2019.1', sha256='a4875c6b6853213083e52ecd303546bdf424568ec67cfc7e51d132a7c037c66a')
    version('2019',   sha256='4d149895826cea785cd3b9a14f4aa743b6ef0df520eca7ee27d438fdc3d73399')
    version('2018.6', sha256='d3e5fbca3cc643d03bf332d576ff85e19aa774b483f148f95cd7d09958372109')
    version('2018.5', sha256='c4c2896af527392496c5e01ef8579058a71b6eebbd695924cd138841c13f07be')
    version('2018.4', sha256='d5604a04787c8a037d4944eeb89792e7c45f6a83c141b20df7ee89c2fb012ed1')
    version('2018.3', sha256='23793c8645480148e9559df96b386b780f92194c80120acce79fcdaae0d81f45')
    version('2018.2', sha256='78bb9bae474736d213342f01fe1a6d00c6939d5c75b367e2e43e7bf29a6d8eca')
    version('2018.1', sha256='c6462217d4ecef2b44fce63cfdf31f9db4f6ff493869899d497a5aef68b05fc5')
    version('2018',   sha256='94f643f1edfaccb57d64b503c7c96f00dec64e8635c054bbaa33855d72c5822d')
    version('2017.8', sha256='1b1357f280e750d42506212adad02f85ac07c9d3e3c0813104f9122ef350497f')
    version('2017.7', sha256='78ad6ec9dd492b9dcc4753938b06716f7458506084adc138ced09aa0aa609b6b')
    version('2017.6', sha256='40d5409a6fd7e214a21fd1949df422ba113fa78fde42a6aac40a2fba36e9bcdb')
    version('2017.5', sha256='3122c87a35fde759567c8579ba36a36037c6df84c3f9c4df6c9e171f866f352f')
    version('2017.4', sha256='ed4f0cfc4acec8a0cf253037e8c555dd32ebe1b80b34fb0e3b2bf54087932562')
    version('2017.3', sha256='00a8b2798c498507572e24c2db7bf4896f05b760a38ed9ba566ffd348a7c6cef')
    version('2017.2', sha256='85e44041d967ce8c70077dbb57941cfa1d351688855aec47eb14c74eb2075f28')
    version('2017.1', sha256='a68bb7926fb9bee2a5f17b293c6d6aa33ccb089c3b321569bd4fe281cf65fa77')
    version('2017',   sha256='c49139279067df1260dae4f0fe7e4d485898ce45e5f7e314c37eb5da8a0c303a')
    version('4.4.6',  sha256='1d6b7e7db9141238c70984103f04280605dbcaa7fbcd049d332d2e73deed4f6d')
    version('4.4.5',  sha256='984308f9dd8a36ff274c124b6f7f7d0ff74d4b7ebdf06511af78e098b5b6e70f')
    version('4.4.4',  sha256='40e94c1adfd13308d207971629316ae9f76639b24f080bae8757c42d35778f10')
    version('4.4.3',  sha256='9acb1c4e71edc3d5004ab9f0ed2bbd697ecec28a4315bbd2be8c5365e8214b90')
    version('4.4.2',  sha256='3f6d7a32ac8b58469de7df3a2fcfe318793241ea39ce73aae1e637dbed833375')
    version('4.4.1',  sha256='d67c5860ba1116b320b0d60a0ce403b088dc19355ab32c28cdaa3e352609713a')
    version('4.4',    sha256='88e37f08ffcfaa24a2caf6c1a9084000cce689cc4b11edea7e89b20ab74ceceb')

    provides('tbb')

    conflicts('%gcc@6.1:', when='@:4.4.3',
              msg='4.4.4 or later required for GCC >= 6.1.')

    variant('shared', default=True,
            description='Builds a shared version of TBB libraries')

    variant('cxxstd',
            default='default',
            values=('default', '98', '11', '14', '17'),
            multi=False,
            description='Use the specified C++ standard when building.')

    variant('tm', default=True,
            description='Enable use of transactional memory on x86')

    # Build and install CMake config files if we're new enough.
    depends_on('cmake@3.0.0:', type='build', when='@2017.0:')

    # Note: see issues #11371 and #8957 to understand why 2019.x patches are
    # specified one at a time.  In a nutshell, it is currently impossible
    # to patch `2019.1` without patching `2019`.  When #8957 is fixed, this
    # can be simplified.

    # Deactivate use of RTM with GCC when on an OS with an elderly assembler.
    # one patch format for 2019.1 and after...
    patch("tbb_gcc_rtm_key_2019U1.patch", level=0, when='@2019.4 %gcc@4.8.0: os=rhel6')
    patch("tbb_gcc_rtm_key_2019U1.patch", level=0, when='@2019.4 %gcc@4.8.0: os=scientific6')
    patch("tbb_gcc_rtm_key_2019U1.patch", level=0, when='@2019.4 %gcc@4.8.0: os=centos6')
    patch("tbb_gcc_rtm_key_2019U1.patch", level=0, when='@2019.3 %gcc@4.8.0: os=rhel6')
    patch("tbb_gcc_rtm_key_2019U1.patch", level=0, when='@2019.3 %gcc@4.8.0: os=scientific6')
    patch("tbb_gcc_rtm_key_2019U1.patch", level=0, when='@2019.3 %gcc@4.8.0: os=centos6')
    patch("tbb_gcc_rtm_key_2019U1.patch", level=0, when='@2019.2 %gcc@4.8.0: os=rhel6')
    patch("tbb_gcc_rtm_key_2019U1.patch", level=0, when='@2019.2 %gcc@4.8.0: os=scientific6')
    patch("tbb_gcc_rtm_key_2019U1.patch", level=0, when='@2019.2 %gcc@4.8.0: os=centos6')
    patch("tbb_gcc_rtm_key_2019U1.patch", level=0, when='@2019.1 %gcc@4.8.0: os=rhel6')
    patch("tbb_gcc_rtm_key_2019U1.patch", level=0, when='@2019.1 %gcc@4.8.0: os=scientific6')
    patch("tbb_gcc_rtm_key_2019U1.patch", level=0, when='@2019.1 %gcc@4.8.0: os=centos6')
    # ...another patch file for 2019 and before
    patch("tbb_gcc_rtm_key.patch", level=0, when='@:2019.0 %gcc@4.8.0: os=rhel6')
    patch("tbb_gcc_rtm_key.patch", level=0, when='@:2019.0 %gcc@4.8.0: os=scientific6')
    patch("tbb_gcc_rtm_key.patch", level=0, when='@:2019.0 %gcc@4.8.0: os=centos6')

    # patch for pedantic warnings (#10836)
    # one patch file for 2019.1 and after...
    patch("gcc_generic-pedantic-2019.patch", level=1, when='@2019.4')
    patch("gcc_generic-pedantic-2019.patch", level=1, when='@2019.3')
    patch("gcc_generic-pedantic-2019.patch", level=1, when='@2019.2')
    patch("gcc_generic-pedantic-2019.patch", level=1, when='@2019.1')
    # ...another patch file for 2019 and before
    patch("gcc_generic-pedantic-4.4.patch", level=1, when='@:2019.0')

    # Patch cmakeConfig.cmake.in to find the libraries where we install them.
    patch("tbb_cmakeConfig.patch", level=0, when='@2017.0:')

    # Some very old systems don't support transactional memory.
    patch("disable-tm.patch", when='~tm')

    def url_for_version(self, version):
        url = 'https://github.com/01org/tbb/archive/{0}.tar.gz'
        if (version[0] >= 2017) and len(version) > 1:
            return url.format('{0}_U{1}'.format(version[0], version[1]))
        else:
            return url.format(version)

    def coerce_to_spack(self, tbb_build_subdir):
        for compiler in ["icc", "gcc", "clang"]:
            fs = glob.glob(join_path(tbb_build_subdir,
                                     "*.%s.inc" % compiler))
            for f in fs:
                lines = open(f).readlines()
                of = open(f, "w")
                for l in lines:
                    if l.strip().startswith("CPLUS ="):
                        of.write("# coerced to spack\n")
                        of.write("CPLUS = $(CXX)\n")
                    elif l.strip().startswith("CONLY ="):
                        of.write("# coerced to spack\n")
                        of.write("CONLY = $(CC)\n")
                    else:
                        of.write(l)

    def install(self, spec, prefix):
        # We need to follow TBB's compiler selection logic to get the proper
        # build + link flags but we still need to use spack's compiler wrappers
        # to accomplish this, we do two things:
        #
        # * Look at the spack spec to determine which compiler we should pass
        #   to tbb's Makefile;
        #
        # * patch tbb's build system to use the compiler wrappers (CC, CXX) for
        #   icc, gcc, clang (see coerce_to_spack());
        #
        self.coerce_to_spack("build")

        if spec.satisfies('%clang'):
            tbb_compiler = "clang"
        elif spec.satisfies('%intel'):
            tbb_compiler = "icc"
        else:
            tbb_compiler = "gcc"

        mkdirp(prefix)
        mkdirp(prefix.lib)

        make_opts = []

        # Static builds of TBB are enabled by including 'big_iron.inc' file
        # See caveats in 'big_iron.inc' for limits on using TBB statically
        # Lore states this file must be handed to make before other options
        if '+shared' not in self.spec:
            make_opts.append("extra_inc=big_iron.inc")

        if spec.variants['cxxstd'].value != 'default':
            make_opts.append('stdver=c++{0}'.
                             format(spec.variants['cxxstd'].value))

        #
        # tbb does not have a configure script or make install target
        # we simply call make, and try to put the pieces together
        #
        make_opts.append("compiler={0}".format(tbb_compiler))
        make(*make_opts)

        # install headers to {prefix}/include
        install_tree('include', prefix.include)

        # install libs to {prefix}/lib
        tbb_lib_names = ["libtbb",
                         "libtbbmalloc",
                         "libtbbmalloc_proxy"]

        for lib_name in tbb_lib_names:
            # install release libs
            fs = glob.glob(join_path("build", "*release", lib_name + ".*"))
            for f in fs:
                install(f, prefix.lib)
            # install debug libs if they exist
            fs = glob.glob(join_path("build", "*debug", lib_name + "_debug.*"))
            for f in fs:
                install(f, prefix.lib)

        if self.spec.satisfies('@2017.0:'):
            # Generate and install the CMake Config file.
            cmake_args = ('-DTBB_ROOT={0}'.format(prefix),
                          '-DTBB_OS={0}'.format(platform.system()),
                          '-P',
                          'tbb_config_generator.cmake')
            with working_dir(join_path(self.stage.source_path, 'cmake')):
                inspect.getmodule(self).cmake(*cmake_args)
