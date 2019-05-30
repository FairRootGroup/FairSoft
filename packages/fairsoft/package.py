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
import compiler
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

    # Add all dependencies here.
    depends_on('gnutls ~guile') #dependency of cmake which has to be build without guile support
    depends_on('cmake@3.11.1+ownlibs', type='build')
    depends_on('googletest@1.7.0:')
    depends_on('boost@1.67.0 cxxstd=11')
    
    depends_on('pythia6@428-alice1')
    depends_on('pythia8@8212')

    depends_on('geant4@10.04.p01 cxxstd=11 ~qt~vecgeom~opengl~x11~motif+threads+data')

    # mesa and libxml2 are dependencies of root which have to be build extra due to the
    # extra build options
    depends_on('mesa~llvm')
    depends_on('libxml2+python')
#    depends_on('root@6.12.06 cxxstd=11 +fortran+gdml+http+memstat+pythia6+pythia8+vc+xrootd+python')
    depends_on('root@6.12.06 cxxstd=11 +fortran+gdml+http+memstat+pythia6+pythia8+vc+xrootd+python~vdt')
    
    depends_on('geant3@v2-5-gcc8')
    depends_on('vgm@4-4')
    depends_on('geant4_vmc@3-6')

    depends_on('fairlogger@1.2.0')
    depends_on('fairmq@1.2.3')

#    depends_on('protobuf@3.4.0')
#    depends_on('flatbuffers@1.9.0')    
#    depends_on('millepede')       

    def install(self, spec, prefix):
        # touch a file in the installation directory
        touch('%s/this-is-a-bundle.txt' % prefix)

