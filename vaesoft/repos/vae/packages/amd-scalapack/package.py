# Copyright 2013-2020 Lawrence Livermore National Security, LLC and other
#   Spack Project Developers. See the top-level COPYRIGHT file for details.
# Copyright 2020 GSI Helmholtz Centre for Heavy Ion Research GmbH,
#   Darmstadt, Germany
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)


from spack import *


class AmdScalapack(MakefilePackage):
    homepage = "https://github.com/amd/scalapack/"
    url = "https://github.com/amd/scalapack/archive/2.1.tar.gz"

    maintainers = ['ChristianTackeGSI']

    version('2.1', sha256='08986130833d3d0d603cd96ba19a76911e4d45bbfa0ae1986d8bcd886814330d')

    depends_on('mpi')
    depends_on('amd.blis')
    depends_on('amd.libflame')

    def edit(self, spec, prefix):
        makeconf = FileFilter('SLmake.inc')
        makeconf.filter(r'^\s*BLASLIB_PATH\s*:=.*$',
                        'BLASLIB_PATH := {0}'.format(spec['blis'].prefix))
        makeconf.filter(r'^\s*LAPACKLIB_PATH\s*:=.*$',
                        'LAPACKLIB_PATH := {0}'.format(spec['libflame'].prefix))
        makeconf.filter(r'^\s*(BLASLIB\s*=.*)/libblis.a.*$',
                        r'\1/lib/libblis.so')
        makeconf.filter(r'^\s*(LAPACKLIB\s*=.*)/libflame.a.*$',
                        r'\1/lib/libflame.so')

    def build(self, spec, prefix):
        make('clean', parallel=False)
        make(parallel=False)

    def install(self, spec, prefix):
        mkdirp(prefix.lib)
        install('libscalapack.a', prefix.lib)
