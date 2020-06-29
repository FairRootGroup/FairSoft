# Copyright 2013-2020 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack import *


class Pythia8(AutotoolsPackage):
    """PYTHIA8 is a program for the generation of high-energy physics events,
       i.e. for the description of collisions at high energies between elementary
       particles such as e+, e-, p and pbar in various combinations."""

    homepage = "http://home.thep.lu.se/~torbjorn/Pythia.html"
    url      = "http://home.thep.lu.se/~torbjorn/pythia8/pythia8244.tgz"

    version('8302', sha256='7372e4cc6f48a074e6b7bc426b040f218ec4a64b0a55e89da6af56933b5f5085')
    version('8301', sha256='51382768eb9aafb97870dca1909516422297b64ef6a6b94659259b3e4afa7f06')
    version('8244', sha256='e34880f999daf19cdd893a187123927ba77d1bf851e30f6ea9ec89591f4c92ca', preferred=True)
    version('8240', sha256='d27495d8ca7707d846f8c026ab695123c7c78c7860f04e2c002e483080418d8d')
    version('8235', sha256='e82f0d6165a8250a92e6aa62fb53201044d8d853add2fdad6d3719b28f7e8e9d')
    version('8230', sha256='332fad0ed4f12e6e0cb5755df0ae175329bc16bfaa2ae472d00994ecc99cd78d')
    version('8212', sha256='f8fb4341c7e8a8be3347eb26b00329a388ccf925313cfbdba655a08d7fd5a70e')

    # Avoid sqrt of negative numbers
    # See: https://github.com/alisw/alidist/pull/2333
    # See: https://github.com/alisw/pythia8/commit/a854fb5c250fe7b7b17e4e43f7dcb03e63ee1364
    patch('ropewalk_sqrt.patch', when='@8240:8244,8301:8302')

    depends_on('rsync', type='build')
    depends_on('hepmc@2:2.99')

    def configure_args(self):
        spec = self.spec
        cfl = ' '.join(spec.compiler_flags['cxxflags'])

        args = ['--with-hepmc2=%s' % spec['hepmc'].prefix,
                '--cxx-common=%s' % cfl,
                '--enable-shared']
        return args

    def setup_environment(self, spack_env, run_env):
        run_env.set('PYTHIA8DATA', '%s/share/Pythia8/xmldoc' % prefix )
        run_env.set('PYTHIA8', '%s' % prefix )
