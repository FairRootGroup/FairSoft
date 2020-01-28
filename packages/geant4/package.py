# Copyright 2013-2019 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack import *
import os
import glob
import subprocess

class Geant4(CMakePackage):
    """Geant4 is a toolkit for the simulation of the passage of particles
    through matter. Its areas of application include high energy, nuclear
    and accelerator physics, as well as studies in medical and space
    science."""

    homepage = "http://geant4.cern.ch/"
    url = "http://geant4.cern.ch/support/source/geant4.10.01.p03.tar.gz"

    version('10.06', sha256='1424c5a0e37adf577f265984956a77b19701643324e87568c5cb69adc59e3199')
    version('10.05.p01', '8a5fa524b5e6e427452e7680d49d5471')
    version('10.04.p03', 'e60a321b691f6b58de54c8a2139b21fa')
    version('10.04.p01', '3f9f5f61d956b2d1d12f009ddd810fd0')
    version('10.04', 'b84beeb756821d0c61f7c6c93a2b83de')
    version('10.03.p03', 'ccae9fd18e3908be78784dc207f2d73b')

    variant('qt', default=False, description='Enable Qt support')
    variant('vecgeom', default=False, description='Enable vecgeom support')
    variant('opengl', default=False, description='Optional OpenGL support')
    variant('x11', default=False, description='Optional X11 support')
    variant('motif', default=False, description='Optional motif support')
    variant('threads', default=True, description='Build with multithreading')
    variant('data', default=True, description='Install geant4 data')
    variant('clhep', default=True, description='Build with extrenal CLHEP')

    variant('cxxstd',
            default='11',
            values=('11', '14', '17'),
            multi=False,
            description='Use the specified C++ standard when building.')

    depends_on('cmake@3.5:', type='build')

    # C++11 support
    depends_on("xerces-c cxxstd=11", when="cxxstd=11")
    depends_on("clhep@2.4.1.3 cxxstd=11", when="@10.06 cxxstd=11 +clhep")
    depends_on("clhep@2.4.1.0 cxxstd=11", when="@10.05.p01 cxxstd=11 +clhep")
    depends_on("clhep@2.4.0.0 cxxstd=11", when="@10.04.p03 cxxstd=11 +clhep")
    depends_on("clhep@2.4.0.0 cxxstd=11", when="@10.04.p01 cxxstd=11 +clhep")
    depends_on("clhep@2.4.0.0 cxxstd=11", when="@10.04 cxxstd=11 +clhep")
    depends_on("clhep@2.3.4.6 cxxstd=11", when="@10.03.p03 cxxstd=11 +clhep")
    depends_on("vecgeom cxxstd=11", when="+vecgeom cxxstd=11")

    # C++14 support
    depends_on("xerces-c cxxstd=14", when="cxxstd=14")
    depends_on("clhep@2.4.1.3 cxxstd=14", when="@10.06 cxxstd=14 +clhep")
    depends_on("clhep@2.4.1.0 cxxstd=14", when="@10.05.p01 cxxstd=14 +clhep")
    depends_on("clhep@2.4.0.0 cxxstd=14", when="@10.04.p03 cxxstd=14 +clhep")
    depends_on("clhep@2.4.0.0 cxxstd=14", when="@10.04.p01 cxxstd=14 +clhep")
    depends_on("clhep@2.4.0.0 cxxstd=14", when="@10.04 cxxstd=14 +clhep")
    depends_on("clhep@2.3.4.6 cxxstd=14", when="@10.03.p03 cxxstd=14 +clhep")
    depends_on("vecgeom cxxstd=14", when="+vecgeom cxxstd=14")

    # C++17 support
    depends_on("xerces-c cxxstd=17", when="cxxstd=17")
    patch('cxx17.patch', when='@:10.03.p99 cxxstd=17')
    patch('cxx17_geant4_10_0.patch', level=1, when='@10.04.00: cxxstd=17 +clhep')
    depends_on("clhep@2.4.1.3 cxxstd=17", when="@10.06 cxxstd=17 +clhep")
    depends_on("clhep@2.4.1.0 cxxstd=17", when="@10.05.p01 cxxstd=17 +clhep")
    depends_on("clhep@2.4.0.0 cxxstd=17", when="@10.04.p03 cxxstd=17 +clhep")
    depends_on("clhep@2.4.0.0 cxxstd=17", when="@10.04.p01 cxxstd=17 +clhep")
    depends_on("clhep@2.4.0.0 cxxstd=17", when="@10.04 cxxstd=17 +clhep")
    depends_on("clhep@2.3.4.6 cxxstd=17", when="@10.03.p03 cxxstd=17 +clhep")
    depends_on("vecgeom cxxstd=17", when="+vecgeom cxxstd=17")

    depends_on("expat")
    depends_on("zlib")
    depends_on("gl", when='+opengl')
    depends_on("glx", when='+opengl+x11')
    depends_on("libx11", when='+x11')
    depends_on("libxmu", when='+x11')
    depends_on("motif", when='+motif')
    depends_on("qt@4.8:4.999", when="+qt")

    # if G4 data not installed with geant4
    # depend on G4 data packages
    # this allows external data installations
    # to avoid duplication

    depends_on('geant4-data@10.06', when='@10.06:10.06.p99 ~data')
    depends_on('geant4-data@10.05', when='@10.05.p00:10.05.p99 ~data')
    depends_on('geant4-data@10.04', when='@10.04.p00:10.04.p99 ~data')
    depends_on('geant4-data@10.03', when='@10.03.p03 ~data')

    def cmake_args(self):
        spec = self.spec

        options = [
            '-DGEANT4_USE_GDML=ON',
            '-DGEANT4_USE_G3TOG4=ON',
            '-DGEANT4_INSTALL_DATA=ON',
            '-DGEANT4_BUILD_TLS_MODEL=global-dynamic',
            '-DGEANT4_USE_SYSTEM_EXPAT=ON',
            '-DGEANT4_USE_SYSTEM_ZLIB=ON',
            '-DXERCESC_ROOT_DIR:STRING=%s' %
            spec['xerces-c'].prefix, ]

        if 'platform=darwin' not in spec:
            if "+x11" in spec and "+opengl" in spec:
                options.append('-DGEANT4_USE_OPENGL_X11=ON')
            if "+motif" in spec and "+opengl" in spec:
                options.append('-DGEANT4_USE_XM=ON')
            if "+x11" in spec:
                options.append('-DGEANT4_USE_RAYTRACER_X11=ON')

        options.append('-DGEANT4_BUILD_CXXSTD=c++{0}'.format(
                       self.spec.variants['cxxstd'].value))

        if '+qt' in spec:
            options.append('-DGEANT4_USE_QT=ON')
            options.append(
                '-DQT_QMAKE_EXECUTABLE=%s' %
                spec['qt'].prefix.bin.qmake)

        if '+vecgeom' in spec:
            options.append('-DGEANT4_USE_USOLIDS=ON')
            options.append('-DUSolids_DIR=%s' % spec[
                'vecgeom'].prefix.lib.CMake.USolids)


        on_or_off = lambda opt: 'ON' if '+' + opt in spec else 'OFF'
        options.append('-DGEANT4_BUILD_MULTITHREADED=' + on_or_off('threads'))

        # install the data with geant4
        options.append('-DGEANT4_INSTALL_DATA=' + on_or_off('data'))

        # use external or internal CLHEP
        options.append('-DGEANT4_USE_SYSTEM_CLHEP=' + on_or_off('clhep'))

        return options

    def url_for_version(self, version):
        """Handle Geant4's unusual version string."""
        return ("http://geant4.cern.ch/support/source/geant4.%s.tar.gz" % version)

    @run_before('cmake')
    def make_data_links(self):
        if '+data' in self.spec:
            return
        spec = self.spec
        version = self.version
        major = version[0]
        minor = version[1]
        if len(version) > 2:
            patch = version[-1]
        else:
            patch = 0
        datadir = 'Geant4-%s.%s.%s' % (major, minor, patch)
        linkdir = 'Geant4-%s.%s.0' % (major, minor)
        with working_dir(join_path(spec.prefix.share, datadir),
                         create=True):
            dirs = glob.glob('%s/%s/*' %
                             (spec['geant4-data'].prefix.share, linkdir))
            for d in dirs:
                os.symlink(d, os.path.basename(d))

    def setup_dependent_environment(self, spack_env, run_env, dep_spec):
        version = self.version
        spec = self.spec
        major = version[0]
        minor = version[1]
        if len(version) > 2:
            patch = version[-1]
        else:
            patch = 0
        datadir = 'Geant4-%s.%s.%s' % (major, minor, patch)
        spack_env.append_path('CMAKE_MODULE_PATH',
                              '{0}/{1}/Modules'.format(
                                  spec.prefix.lib64, datadir))

        # Get the tuple of installed data sets from the geant4 config
        # Split it in parts to get the name of the environment variable
        # and the corresponding installation directory.
        # The same information is also needed for the run environment
        # of Geant4 but the config file is not yet installed when
        # setup_environment is executed.
        # TODO: find a way to setup the environment also for Geant4
        command = "%s/geant4-config" % spec.prefix.bin
        output = subprocess.check_output([ command, "--datasets"]).decode("ascii")
        for line in output.split("\n"):
            item = line.split(" ")
            if item[0]:
                run_env.set(item[1], item[2])
