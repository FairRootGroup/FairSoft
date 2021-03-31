# Copyright 2013-2021 Lawrence Livermore National Security, LLC and other
#   Spack Project Developers. See the top-level COPYRIGHT file for details.
# Copyright 2020-2021 GSI Helmholtz Centre for Heavy Ion Research GmbH,
#   Darmstadt, Germany
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)



class FairsoftBundle(BundlePackage):
    """Provide some sort of 'include' for our environments"""

    homepage = "https://github.com/FairRootGroup/FairSoft"

    # To get only the flags, but no version pinnings:
    version('develop')
    # For the next release (would love to call it "next", but that is
    # not sorted correctly by spack)
    version('master')
    # Releases:
    version('21.3')
    version('20.11')
    version('19.6')

    variant('graphics', default=False)
    variant('mt', default=False)

    # Pin some variants:
    depends_on('geant4 ~threads', when='~mt')
    depends_on('geant4 +threads', when='+mt')
    depends_on('geant4 ~qt~vecgeom~opengl~x11~motif')

    # Generic ROOT dependencies
    depends_on('root +fortran+pythia6+pythia8+vc~vdt')
    # Mostly for the experiments:
    depends_on('root +python+tmva+mlp+xrootd+sqlite')
    depends_on('root +spectrum', when='@20.11:')
    depends_on('root ~x~opengl~aqua', when='~graphics')
    depends_on('root +x+opengl', when='+graphics')
    depends_on('root +aqua', when='+graphics platform=darwin')

    # mar21:
    depends_on('pythia8@8303',          when='@21.3')
    # geant4 pinning breaks concretization
    depends_on('root@6.22.08',          when='@21.3')
    depends_on('vmc@1-0-p3',            when='@21.3')
    depends_on('geant3@3.8',            when='@21.3')
    depends_on('vgm@4-8',               when='@21.3')
    depends_on('geant4-vmc@5-3',        when='@21.3')
    depends_on('fairsoft-config@mar21', when='@21.3', type='run')

    # nov20:
    depends_on('pythia8@8303',          when='@20.11')
    # geant4 pinning breaks concretization
    depends_on('root@6.20.08',          when='@20.11')
    depends_on('vmc@1-0-p3',            when='@20.11')
    depends_on('geant3@3.7',            when='@20.11')
    depends_on('vgm@4-8',               when='@20.11')
    depends_on('geant4-vmc@5-2',        when='@20.11')
    depends_on('fairsoft-config@nov20', when='@20.11', type='run')

    # jun19:
    depends_on('pythia8@8240',          when='@19.6')
    # geant4 pinning breaks concretization
    depends_on('root@6.16.00 +memstat', when='@19.6')
    depends_on('geant3@2.7',            when='@19.6')
    depends_on('vgm@4-5',               when='@19.6')
    depends_on('geant4-vmc@4-0-p1',     when='@19.6')
    depends_on('fairsoft-config@jun19', when='@19.6', type='run')
