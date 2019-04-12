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


class Geant4(CMakePackage):
    """Geant4 is a toolkit for the simulation of the passage of particles
    through matter. Its areas of application include high energy, nuclear
    and accelerator physics, as well as studies in medical and space
    science."""

    homepage = "http://geant4.cern.ch/"
    url = "http://geant4.cern.ch/support/source/geant4.10.01.p03.tar.gz"

    version('10.02.p02', '6aae1d0fc743b0edc358c5c8fbe48657')
    version('10.02.p01', 'b81f7082a15f6a34b720b6f15c6289cfe4ddbbbdcef0dc52719f71fac95f7f1c')
    version('10.01.p03', '4fb4175cc0dabcd517443fbdccd97439')

    variant('qt', default=True, description='Enable Qt support')
    variant('mt', default=True, description='Build multithreade libraries.')
    variant('expat', default=True, description='Enable Expat support')
    variant('xercesc', default=True, description='Enable Xerces-C support')
    variant('vecgeom', default=True, description='Enable VecGeom support')
    variant('cxx11', default=True, description='Compile using c++11 dialect.')
    variant('cxx14', default=False, description='Compile using c++14 dialect.')

    depends_on('cmake@3.5:', type='build')

    depends_on("clhep@2.3.1.1~cxx11+cxx14", when="@10.02.p02")
    depends_on("clhep@2.3.1.1+cxx11", when="@10.02.p01+cxx11")
    depends_on("clhep@2.3.1.1+cxx14", when="@10.02.p01+cxx14")
    depends_on("clhep@2.2.0.4~cxx11+cxx14", when="@10.01.p03")
    depends_on("expat", when="+expat")
    depends_on("zlib")
    depends_on("vecgeom", when="+vecgeom")
    depends_on("xerces-c", when="+xercesc")
    depends_on("qt@4.8:", when="+qt")

    def cmake_args(self):
        spec = self.spec

        options = [
            '-DGEANT4_USE_SYSTEM_CLHEP=ON',
            '-DGEANT4_USE_G3TOG4=ON',
            '-DGEANT4_INSTALL_DATA=ON',
            '-DGEANT4_BUILD_TLS_MODEL=global-dynamic',
            '-DGEANT4_USE_SYSTEM_ZLIB=ON']

        arch = platform.system().lower()
        if arch != 'darwin':
            options.append('-DGEANT4_USE_OPENGL_X11=ON')
            options.append('-DGEANT4_USE_XM=ON')
            options.append('-DGEANT4_USE_RAYTRACER_X11=ON')
        else:
            options.append('-DGEANT4_USE_OPENGL_X11=OFF')
            options.append('-DGEANT4_USE_XM=OFF')
            options.append('-DGEANT4_USE_RAYTRACER_X11=OFF')

        if "+mt" in spec:
            options.append('-DGEANT4_BUILD_MULTITHREADED=ON')
        else:    
            options.append('-DGEANT4_BUILD_MULTITHREADED=OFF')
            
        if '+xercesc' in spec:
            options.append('-DXERCESC_ROOT_DIR:STRING=%s' % 
            spec['xerces-c'].prefix)
            options.append('-DGEANT4_USE_GDML=ON')

        if '+vecgeom' in spec:
            options.append('-DUSolids_DIR=%s' %
            join_path(spec['vecgeom'].prefix, 'lib/CMake/USolids'))
            options.append('-DGEANT4_USE_USOLIDS=ON')

        if '+expat' in spec:
            options.append('-DGEANT4_USE_SYSTEM_EXPAT=ON')
        else:
            options.append('-DGEANT4_USE_SYSTEM_EXPAT=OFF')

        if '+cxx11' in spec:
            options.append('-DGEANT4_BUILD_CXXSTD=c++11')
        if '+cxx14' in spec:
            options.append('-DGEANT4_BUILD_CXXSTD=c++14')
        if '+cxx1y' in spec:
            options.append('-DGEANT4_BUILD_CXXSTD=c++14')

        if '+qt' in spec:
            options.append('-DGEANT4_USE_QT=ON')
            options.append(
                '-DQT_QMAKE_EXECUTABLE=%s' %
                spec['qt'].prefix + '/bin/qmake'
            )

        return options

    def url_for_version(self, version):
        """Handle Geant4's unusual version string."""
        return ("http://geant4.cern.ch/support/source/geant4.%s.tar.gz" % version)
