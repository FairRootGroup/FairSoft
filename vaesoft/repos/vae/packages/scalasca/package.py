# Copyright 2013-2020 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)


from spack import *


class Scalasca(AutotoolsPackage):
    """Scalasca is a software tool that supports the performance optimization
       of parallel programs by measuring and analyzing their runtime
       behavior. The analysis identifies potential performance
       bottlenecks - in particular those concerning communication and
       synchronization - and offers guidance in exploring their causes.

    """

    homepage = "http://www.scalasca.org"
    url = "http://apps.fz-juelich.de/scalasca/releases/scalasca/2.1/dist/scalasca-2.1.tar.gz"
    list_url = "https://scalasca.org/scalasca/front_content.php?idart=1072"

    version('2.5', sha256='7dfa01e383bfb8a4fd3771c9ea98ff43772e415009d9f3c5f63b9e05f2dde0f6')
    version('2.4',   sha256='4a895868258030f700a635eac93d36764f60c8c63673c7db419ea4bcc6b0b760')
    version('2.3.1', sha256='8ff485d03ab2c02a5852d346ae041a191c60b4295f8f9b87fe58cd36977ba558')
    version('2.2.2', sha256='909567ca294366119bbcb7e8122b94f43982cbb328e18c6f6ce7a722d72cd6d4')
    version('2.1',   sha256='fefe43f10becf7893863380546c80ac8db171a3b1ebf97d0258602667572c2fc')

    depends_on('zlib')
    depends_on("mpi")

    # version 2.4+
    depends_on('cubew@4.4:', when='@2.4:')

    # version 2.3+
    depends_on('otf2@2:', when='@2.3:')

    # version 2.3
    depends_on('cube@4.3', when='@2.3:2.3.99')

    # version 2.1 - 2.2
    depends_on('cube@4.2', when='@2.1:2.2.999')
    depends_on('otf2@1.4', when='@2.1:2.2.999')

    def url_for_version(self, version):
        return 'http://apps.fz-juelich.de/scalasca/releases/scalasca/{0}/dist/scalasca-{1}.tar.gz'.format(version.up_to(2), version)

    def configure_args(self):
        spec = self.spec

        config_args = ["--enable-shared"]

        if spec.satisfies('@2.4:'):
            config_args.append("--with-cube=%s" % spec['cubew'].prefix.bin)
        else:
            config_args.append("--with-cube=%s" % spec['cube'].prefix.bin)

        config_args.append("--with-otf2=%s" % spec['otf2'].prefix.bin)

        if self.spec['mpi'].name == 'openmpi':
            config_args.append("--with-mpi=openmpi")
        elif self.spec.satisfies('^mpich@3:'):
            config_args.append("--with-mpi=mpich3")

        return config_args

    def setup_build_environment(self, env):
        env.set('LIBZ_INCLUDE', self.spec['zlib'].prefix.include)
        env.set('LIBZ_LIB', self.spec['zlib'].prefix.lib)
