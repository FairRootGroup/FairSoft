# Copyright 2013-2020 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)


from spack import *


class Slurm(AutotoolsPackage):
    """Slurm is an open source, fault-tolerant, and highly scalable cluster
    management and job scheduling system for large and small Linux clusters.

    Slurm requires no kernel modifications for its operation and is relatively
    self-contained. As a cluster workload manager, Slurm has three key
    functions. First, it allocates exclusive and/or non-exclusive access to
    resources (compute nodes) to users for some duration of time so they can
    perform work. Second, it provides a framework for starting, executing,
    and monitoring work (normally a parallel job) on the set of allocated
    nodes. Finally, it arbitrates contention for resources by managing a
    queue of pending work.
    """

    homepage = 'https://slurm.schedmd.com'
    url = 'https://github.com/SchedMD/slurm/archive/slurm-17-02-6-1.tar.gz'

    version('18-08-9-1', sha256='32eb0b612ca18ade1e35c3c9d3b4d71aba2b857446841606a9e54d0a417c3b03')
    version('18-08-0-1', sha256='62129d0f2949bc8a68ef86fe6f12e0715cbbf42f05b8da6ef7c3e7e7240b50d9')
    version('17-11-9-2', sha256='6e34328ed68262e776f524f59cca79ac75bcd18030951d45ea545a7ba4c45906')
    version('17-02-6-1', sha256='97b3a3639106bd6d44988ed018e2657f3d640a3d5c105413d05b4721bc8ee25e')

    variant('gtk', default=False, description='Enable GTK+ support')
    variant('mariadb', default=False, description='Use MariaDB instead of MySQL')

    variant('hwloc', default=False, description='Enable hwloc support')
    variant('hdf5', default=False, description='Enable hdf5 support')
    variant('readline', default=True, description='Enable readline support')
    variant('pmix', default=False, description='Enable PMIx support')
    variant('sysconfdir', default='none')

    # TODO: add variant for BG/Q and Cray support

    # TODO: add support for checkpoint/restart (BLCR)

    # TODO: add support for lua

    depends_on('curl')
    depends_on('glib')
    depends_on('json-c')
    depends_on('lz4')
    depends_on('munge')
    depends_on('openssl')
    depends_on('pkgconfig', type='build')
    depends_on('readline', when='+readline')
    depends_on('zlib')

    depends_on('gtkplus', when='+gtk')
    depends_on('hdf5', when='+hdf5')
    depends_on('hwloc', when='+hwloc')
    depends_on('mariadb', when='+mariadb')
    depends_on('pmix', when='+pmix')

    def configure_args(self):

        spec = self.spec

        args = [
            '--with-libcurl={0}'.format(spec['curl'].prefix),
            '--with-json={0}'.format(spec['json-c'].prefix),
            '--with-lz4={0}'.format(spec['lz4'].prefix),
            '--with-munge={0}'.format(spec['munge'].prefix),
            '--with-ssl={0}'.format(spec['openssl'].prefix),
            '--with-zlib={0}'.format(spec['zlib'].prefix),
        ]

        if '~gtk' in spec:
            args.append('--disable-gtktest')

        if '~readline' in spec:
            args.append('--without-readline')

        if '+hdf5' in spec:
            args.append(
                '--with-hdf5={0}'.format(spec['hdf5'].prefix.bin.h5cc)
            )
        else:
            args.append('--without-hdf5')

        if '+hwloc' in spec:
            args.append('--with-hwloc={0}'.format(spec['hwloc'].prefix))
        else:
            args.append('--without-hwloc')

        if '+pmix' in spec:
            args.append('--with-pmix={0}'.format(spec['pmix'].prefix))
        else:
            args.append('--without-pmix')

        sysconfdir = self.spec.variants['sysconfdir'].value
        if sysconfdir != 'none':
            args.append('--sysconfdir={}'.format(sysconfdir))

        return args

    def install(self, spec, prefix):
        make('install')
        make('-C', 'contribs/pmi2', 'install')
