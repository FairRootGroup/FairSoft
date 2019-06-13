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


class Nanomsg(CMakePackage):
    """The nanomsg library is a simple high-performance implementation of several "scalability protocols"""

    homepage = "https://nanomsg.org/"
    url = "https://github.com/nanomsg/nanomsg/archive/1.0.0.tar.gz"

    version('1.1.5', '272db464bac1339b6cea060dd63b22d4')
    version('1.0.0', '6f56ef28c93cee644e8c4aaaef7cfb55')
