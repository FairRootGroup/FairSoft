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
#     spack install geant3
#
# You can edit this file again by typing:
#
#     spack edit geant3
#
# See the Spack documentation for more information on packaging.
# ----------------------------------------------------------------------------

from spack import *


class Fairlogger(CMakePackage):
    """Lightweight and fast C++ Logging Library"""

    # FIXME: Add a proper url for your package's homepage here.
    homepage = "https://github.com/FairRootGroup/FairLogger"

    url      = "https://github.com/fuhlig1/FairLogger/archive/v1.2.0.tar.gz"

    version('1.2.0', '169417786f12411635c670ea3634c880')


    # add correct version info for FairLoger from github tarball
    patch('correct_version_info_1.2.0.patch', when='@1.2.0', level=0)
    