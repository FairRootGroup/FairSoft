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

    version('8235', 'eed56d357dc91df4571c2a65d60f1af5')
    version('8230', '5362429333f43bd1f7621a599bae5a24')
    version('8212', '0886d1b2827d8f0cd2ae69b925045f40')

    depends_on('hepmc@2.06.09')

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
