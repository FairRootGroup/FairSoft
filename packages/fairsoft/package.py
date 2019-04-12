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
    version('17.10', 'd3aee3525b04e1c70ccd4d5be5bf7fbf')

    # Add all dependencies here.
    depends_on('cmake@3.9.4', type='build')
    depends_on('gsl@1.16')
    depends_on('googletest@1.7.0')

    depends_on('boost@1.64.0 clanglibcpp=True', when=(platform == 'darwin'))
    depends_on('boost@1.64.0', when=(platform != 'darwin'))

    depends_on('pythia6@428-alice1')
    depends_on('hepmc@2.06.09')     # also required for pythia8, so duplicate here 
    depends_on('pythia8@8212')

#    'c++11' in compiler.flags['cxxflags']    
    depends_on('geant4@10.02.p01~qt+cxx11~xercesc~vecgeom~expat~mt')   # check if c++11 or c++14 is in CXXFLAGS to build Geant4 accordingly

    def install(self, spec, prefix):
        # touch a file in the installation directory
        touch('%s/this-is-a-bundle.txt' % prefix)

