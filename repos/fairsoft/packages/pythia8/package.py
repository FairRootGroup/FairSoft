# Copyright 2013-2021 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack import *


class Pythia8(AutotoolsPackage):
    """PYTHIA8 is a program for the generation of high-energy physics events,
       i.e. for the description of collisions at high energies between elementary
       particles such as e+, e-, p and pbar in various combinations."""

    homepage = "https://pythia.org/"

    maintainers = ['ChristianTackeGSI']

    version('8304', sha256='65c6165d61cabefb1594998ff2afebd12616def9bb5d18524212bc5886ca8f68')
    version('8303', sha256='9093351829f92d81c60c719bfb007b1e89efb4307f4c8957407406bf3281a6f7')
    version('8302', sha256='7aae73eabdd38ebbcf7998f63c271ae9b397522497a7ee67a9505b9baae1cb1c')
    version('8301', sha256='bcf1f4d96d76c550338aa8a0eff9c2c2085dadbb440df849062ff6b2032fbfd9')
    version('8244', sha256='6f1bb061bd5a708efb08fe0b1b68050174b11f817f470b5681f0afd82cb45300')
    version('8240', sha256='3d71cae2b6fc451910b69a18ee4f6d527c5ad10e32982a0dce5f6449a10c3ff1')
    version('8235', sha256='ef9a1448a09b317d6fa21e43bc706854ac01d1087882600ec31c508c57a9a97e')
    version('8230', sha256='38c9d2bc8996b202f0a1037733d5e50f2deb447f25a3e89a4ecfab7dae0c5495')
    version('8212', sha256='5631cf828ddc37c3a6a5dcce6366bcb9fd80cdd26d363ea197e8cb34aa2eb898')

    # Avoid sqrt of negative numbers
    # See: https://github.com/alisw/alidist/pull/2333
    # See: https://github.com/alisw/pythia8/commit/a854fb5c250fe7b7b17e4e43f7dcb03e63ee1364
    # See: https://github.com/alisw/alidist/pull/2336
    # See: https://github.com/alisw/pythia8/commit/f97ec11943af269e3b08634c03339ae4189b3bbe
    patch('ropewalk_sqrt.patch', when='@8240:8244,8301:8302')

    depends_on('rsync', type='build')
    depends_on('hepmc@2:2.99')

    def configure_args(self):
        spec = self.spec
        cfl = ' '.join(spec.compiler_flags['cxxflags'])

        args = ['--with-hepmc2=%s' % spec['hepmc'].prefix,
                '--cxx-common=%s' % cfl]
        if self.spec.satisfies('@:8299'):
            args.append('--enable-shared')
        return args

    def setup_environment(self, spack_env, run_env):
        run_env.set('PYTHIA8DATA', '%s/share/Pythia8/xmldoc' % prefix )
        run_env.set('PYTHIA8', '%s' % prefix )

    def url_for_version(self, version):
        url = "https://pythia.org/download/pythia{0}/pythia{1}.tgz"
        return url.format(str(version)[:2], version)
