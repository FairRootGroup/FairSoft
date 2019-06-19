# Copyright 2013-2019 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack import *
import os
import glob


class Geant4Data(Package):
    """An umbrella package to hold Geant4 data packages"""

    homepage = "http://geant4.cern.ch"
    url      = "http://geant4-data.web.cern.ch/geant4-data/ReleaseNotes/ReleaseNotes4.10.3.html"

    version('10.03.p03', '2248ad436613897d9fad93bdb99d9446', expand=False)
    version('10.04.p01', 'c49194b96e65ed4527d34d22a9860972', expand=False)
    version('10.04.p03', 'c49194b96e65ed4527d34d22a9860972', expand=False)
    version('10.05.p01', 'd43b9cc4418afe67a7b444727810827a', expand=False)
    version('10.04', 'c49194b96e65ed4527d34d22a9860972', expand=False)

    # geant4@10.03.p03
    depends_on("g4abla@3.0", when='@10.03.p03 ')
    depends_on("g4emlow@6.50", when='@10.03.p03 ')
    depends_on("g4ndl@4.5", when='@10.03.p03 ')
    depends_on("g4neutronxs@1.4", when='@10.03.p03 ')
    depends_on("g4saiddata@1.1", when='@10.03.p03 ')
    depends_on("g4ensdfstate@2.1", when='@10.03.p03 ')
    depends_on("g4photonevaporation@4.3.2", when='@10.03.p03 ')
    depends_on("g4pii@1.3", when='@10.03.p03 ')
    depends_on("g4radioactivedecay@5.1.1", when='@10.03.p03 ')
    depends_on("g4realsurface@1.0", when='@10.03.p03 ')
    depends_on("g4tendl@1.3", when='@10.03.p03 ')
    # geant4@10.04
    depends_on("g4abla@3.1", when='@10.04 ')
    depends_on("g4emlow@7.3", when='@10.04 ')
    depends_on("g4ndl@4.5", when='@10.04 ')
    depends_on("g4neutronxs@1.4", when='@10.04 ')
    depends_on("g4saiddata@1.1", when='@10.04 ')
    depends_on("g4ensdfstate@2.2", when='@10.04 ')
    depends_on("g4photonevaporation@5.2", when='@10.04 ')
    depends_on("g4pii@1.3", when='@10.04 ')
    depends_on("g4radioactivedecay@5.2", when='@10.04 ')
    depends_on("g4realsurface@2.1", when='@10.04 ')
    depends_on("g4tendl@1.3.2", when='@10.04 ')
    # geant4@10.04.p01
    depends_on("g4abla@3.1", when='@10.04.p01')
    depends_on("g4emlow@7.3", when='@10.04.p01')
    depends_on("g4ndl@4.5", when='@10.04.p01')
    depends_on("g4neutronxs@1.4", when='@10.04.p01')
    depends_on("g4saiddata@1.1", when='@10.04.p01')
    depends_on("g4ensdfstate@2.2", when='@10.04.p01')
    depends_on("g4photonevaporation@5.2", when='@10.04.p01')
    depends_on("g4pii@1.3", when='@10.04.p01')
    depends_on("g4radioactivedecay@5.2", when='@10.04.p01')
    depends_on("g4realsurface@2.1", when='@10.04.p01')
    depends_on("g4tendl@1.3.2", when='@10.04.p01')
    # geant4@10.04.p03
    depends_on("g4abla@3.1", when='@10.04.p03')
    depends_on("g4emlow@7.3", when='@10.04.p03')
    depends_on("g4ndl@4.5", when='@10.04.p03')
    depends_on("g4neutronxs@1.4", when='@10.04.p03')
    depends_on("g4saiddata@1.1", when='@10.04.p03')
    depends_on("g4ensdfstate@2.2", when='@10.04.p03')
    depends_on("g4photonevaporation@5.2", when='@10.04.p03')
    depends_on("g4pii@1.3", when='@10.04.p03')
    depends_on("g4radioactivedecay@5.2", when='@10.04.p03')
    depends_on("g4realsurface@2.1", when='@10.04.p03')
    depends_on("g4tendl@1.3.2", when='@10.04.p03')
    # geant4@10.05.p01
    depends_on("g4ndl@4.5", when='@10.05.p01')
    depends_on("g4emlow@7.7", when='@10.05.p01')
    depends_on("g4photonevaporation@5.3", when='@10.05.p01')
    depends_on("g4radioactivedecay@5.3", when='@10.05.p01')
    depends_on("g4saiddata@2.0", when='@10.05.p01')
    depends_on("g4particlexs@1.1", when='@10.05.p01')
    depends_on("g4abla@3.1", when='@10.05.p01')
    depends_on("g4incl@1.0", when='@10.05.p01')
    depends_on("g4pii@1.3", when='@10.05.p01')
    depends_on("g4ensdfstate@2.2", when='@10.05.p01')
    depends_on("g4realsurface@2.1.1", when='@10.05.p01')
    depends_on("g4tendl@1.3.2", when='@10.05.p01')

    def install(self, spec, prefix):
        spec = self.spec
        version = self.version
        major = version[0]
        minor = version[1]
        if len(version) > 2:
            patch = version[-1]
        else:
            patch = 0
        data = 'Geant4-%s.%s.%s/data' % (major, minor, patch)
        datadir = join_path(spec.prefix.share, data)
        with working_dir(datadir, create=True):
            for d in glob.glob('%s/share/data/*' %
                               spec['g4abla'].prefix):
                dest = 'G4ABLA' + '{0}'.format(spec['g4abla'].version)
                os.symlink(d, dest)
            for d in glob.glob('%s/share/data/*' %
                               spec['g4emlow'].prefix):
                dest = 'G4EMLOW' + '{0}'.format(spec['g4emlow'].version)
                os.symlink(d, dest)
            for d in glob.glob('%s/share/data/*' %
                               spec['g4ndl'].prefix):
                dest = 'G4NDL' + '{0}'.format(spec['g4ndl'].version)
                os.symlink(d, dest)
            for d in glob.glob('%s/share/data/*' %
                               spec['g4saiddata'].prefix):
                dest = 'G4SAIDDATA' + '{0}'.format(spec['g4saiddata'].version)
                os.symlink(d, dest)
            for d in glob.glob('%s/share/data/*' %
                               spec['g4ensdfstate'].prefix):
                dest = 'G4ENSDFSTATE' + '{0}'.format(spec['g4ensdfstate'].version)
                os.symlink(d, dest)
            for d in glob.glob('%s/share/data/*' %
                               spec['g4photonevaporation'].prefix):
                dest = 'PhotonEvaporation' + '{0}'.format(spec['g4photonevaporation'].version)
                os.symlink(d, dest)
            for d in glob.glob('%s/share/data/*' %
                               spec['g4pii'].prefix):
                dest = 'G4PII' + '{0}'.format(spec['g4pii'].version)
                os.symlink(d, dest)
            for d in glob.glob('%s/share/data/*' %
                               spec['g4radioactivedecay'].prefix):
                dest = 'RadioactiveDecay' + '{0}'.format(spec['g4radioactivedecay'].version)
                os.symlink(d, dest)
            for d in glob.glob('%s/share/data/*' %
                               spec['g4realsurface'].prefix):
                dest = 'RealSurface' + '{0}'.format(spec['g4realsurface'].version)
                os.symlink(d, dest)
            for d in glob.glob('%s/share/data/*' %
                               spec['g4tendl'].prefix):
                dest = 'G4TENDL' + '{0}'.format(spec['g4tendl'].version)
                os.symlink(d, dest)
            if minor < 5:
                for d in glob.glob('%s/share/data/*' %
                               spec['g4neutronxs'].prefix):
                    dest = 'G4NEUTRONXS' + '{0}'.format(spec['g4neutronxs'].version)
                    os.symlink(d, dest)
            else:
                for d in glob.glob('%s/share/data/*' %
                               spec['g4particlexs'].prefix):
                    dest = 'G4PARTICLEXS' + '{0}'.format(spec['g4particlexs'].version)
                    os.symlink(d, dest)
                for d in glob.glob('%s/share/data/*' %
                               spec['g4incl'].prefix):
                    dest = 'G4INCL' + '{0}'.format(spec['g4incl'].version)
                    os.symlink(d, dest)



    def url_for_version(self, version):
        """Handle version string."""
        url = 'http://geant4-data.web.cern.ch/geant4-data/ReleaseNotes/'
        url = url + 'ReleaseNotes4.{0}.{1}.html'.format(version[0], version[1])
        return url
