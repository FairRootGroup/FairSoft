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
#     spack install dds-control
#
# You can edit this file again by typing:
#
#     spack edit dds-control
#
# See the Spack documentation for more information on packaging.
# ----------------------------------------------------------------------------

from spack import *


class DdsControl(CMakePackage):
    """FIXME: Put a proper description of your package here."""

    # FIXME: Add a proper url for your package's homepage here.
    homepage = "http://www.example.com"
    git      = "https://github.com/FairRootGroup/DDS-control.git"

    version('master', branch='master')

    # FIXME: Add dependencies if required.
    depends_on('protobuf')
    depends_on('grpc')
    depends_on('dds@master')
    depends_on('fairmq@dev')

    def cmake_args(self):
        args = []
        args.append('-DProtobuf_DIR={0}'.format(self.spec['protobuf'].prefix))
        args.append('-Dgrpc_DIR={0}'.format(self.spec['grpc'].prefix))
        args.append('-DDDS_DIR={0}'.format(self.spec['dds'].prefix))
        args.append('-DFairMQ_DIR={0}'.format(self.spec['fairmq'].prefix))
        return args
