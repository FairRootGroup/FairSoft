# Copyright 2013-2019 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

# ----------------------------------------------------------------------------
# If you submit this package back to Spack as a pull request,
# please first remove this boilerplate and all FIXME comments.
#
# This is a template package file for Spack.  We've put "FIXME"
# next to all the things you'll want to change. Once you've handled
# them, you can save this file and test your package like this:
#
#     spack install odc
#
# You can edit this file again by typing:
#
#     spack edit odc
#
# See the Spack documentation for more information on packaging.
# ----------------------------------------------------------------------------

from spack import *


class Odc(CMakePackage):
    """Online Device Control (ODC).
       The Online Device Control project control/communicate with a graph (topology) of FairMQ devices using DDS or PMIx."""

    homepage = "https://github.com/FairRootGroup/ODC"
    git      = "https://github.com/FairRootGroup/ODC.git"

    version('master', branch='master')

    depends_on('boost@1.67.0: cxxstd=11 +container')
    depends_on('cmake@3.11:', type='build')
    depends_on('protobuf')
    depends_on('grpc')
    depends_on('dds@master')
    depends_on('fairmq@dev')

    def cmake_args(self):
        args = []
        args.append('-DBoost_NO_BOOST_CMAKE=ON')
        args.append('-DBOOST_ROOT={0}'.format(self.spec['boost'].prefix))
        args.append('-DProtobuf_DIR={0}'.format(self.spec['protobuf'].prefix))
        args.append('-Dgrpc_DIR={0}'.format(self.spec['grpc'].prefix))
        args.append('-DDDS_DIR={0}'.format(self.spec['dds'].prefix))
        args.append('-DFairMQ_DIR={0}'.format(self.spec['fairmq'].prefix))
        return args
