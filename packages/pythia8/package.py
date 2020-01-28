##############################################################################
# Copyright (c) 2013-2017, Lawrence Livermore National Security, LLC.
# Produced at the Lawrence Livermore National Laboratory.
#
# This file is part of Spack.
# Created by Todd Gamblin, tgamblin@llnl.gov, All rights reserved.
# LLNL-CODE-647188
#
# For details, see https://github.com/spack/spack
# Please also see the NOTICE and LICENSE files for our notice and the LGPL.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License (as
# published by the Free Software Foundation) version 2.1, February 1999.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the IMPLIED WARRANTY OF
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the terms and
# conditions of the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
##############################################################################
from spack import *


class Pythia8(AutotoolsPackage):
    """PYTHIA8 is a program for the generation of high-energy physics events,
       i.e. for the description of collisions at high energies between elementary
       particles such as e+, e-, p and pbar in various combinations."""

    homepage = "http://home.thep.lu.se/~torbjorn/Pythia.html"
    url      = "http://home.thep.lu.se/~torbjorn/pythia8/pythia8212.tgz"

    version('8301', sha256='51382768eb9aafb97870dca1909516422297b64ef6a6b94659259b3e4afa7f06')
    version('8240', sha256='d27495d8ca7707d846f8c026ab695123c7c78c7860f04e2c002e483080418d8d')
    version('8235', sha256='e82f0d6165a8250a92e6aa62fb53201044d8d853add2fdad6d3719b28f7e8e9d')
    version('8230', sha256='332fad0ed4f12e6e0cb5755df0ae175329bc16bfaa2ae472d00994ecc99cd78d')
    version('8212', sha256='f8fb4341c7e8a8be3347eb26b00329a388ccf925313cfbdba655a08d7fd5a70e')

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
