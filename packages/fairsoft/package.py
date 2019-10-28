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
import platform
#import compiler
#import os
#import sys


class Fairsoft(Package):
    """Meta package to install all dependencies which are needed to properly install
       and run FairRoot. No url or homepage is defined, only all packages whcih are
       needed are defined as dependencies. """


    homepage = ""
    url      = "https://github.com/fuhlig1/fairsoft_description/archive/17.10.tar.gz"

    # Development versions
    version('may18', '07e4938113b8a520a1d5dc67e7fbce50')

    variant('x', default=True, description='Enable graphical components')
    variant('opengl', default=True, description='Enable opengl support')

    variant('sim', default=True, description='Enable simulation engines and event generators')
    variant('python', default=True, description='Enable python bindings for ROOT')
    variant('g4mt', default=False, description='GEANT4 in multithreaded mode')

    # Add all dependencies here.
    depends_on('gnutls ~guile') #dependency of cmake which has to be build without guile support
    depends_on('cmake@3.13.4: +ownlibs', type='build')
    depends_on('googletest@1.8.1:')

    depends_on('pythia6@428-alice1', when='+sim')
    depends_on('pythia8@8240', when='+sim')

    depends_on('mesa~llvm', when="+opengl")
    depends_on('libxml2+python', when='+python')
    depends_on('libxml2~python', when='~python')

    depends_on('boost@1.68.0 cxxstd=11 +container')

    depends_on('geant4@10.05.p01 cxxstd=11 ~qt~vecgeom~opengl~x11~motif~data~clhep+threads', when='+sim+g4mt')
    depends_on('geant4@10.05.p01 cxxstd=11 ~qt~vecgeom~opengl~x11~motif~data~clhep~threads', when='+sim~g4mt')

    depends_on('root@6.16.00 cxxstd=11 +fortran+gdml+http+memstat+pythia6+pythia8+vc~vdt')
    depends_on('root@6.16.00 cxxstd=11 +fortran+gdml+http+memstat+pythia6+pythia8+vc~vdt~opengl', when="~opengl")
    depends_on('root@6.16.00 cxxstd=11 +fortran+gdml+http+memstat+pythia6+pythia8+vc~vdt~x', when="~x")
    depends_on('root@6.16.00 cxxstd=11 +fortran+gdml+http+memstat+pythia6+pythia8+vc~vdt~python', when="~python")

    depends_on('geant3@v2-7_fairsoft', when='+sim')
    depends_on('vgm@4-5', when='+sim')
    depends_on('geant4_vmc@4-0-p1', when='+sim')

    depends_on('fairlogger@1.4.0')
    depends_on('fairmq@1.4.3')

#    depends_on('protobuf@3.4.0')
#    depends_on('flatbuffers@1.9.0')
#    depends_on('millepede')

    def install(self, spec, prefix):
        # touch a file in the installation directory
        touch('%s/this-is-a-bundle.txt' % prefix)

