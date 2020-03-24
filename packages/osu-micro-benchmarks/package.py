
from spack import *


class OsuMicroBenchmarks(AutotoolsPackage):
    """FIXME: Put a proper description of your package here."""

    # FIXME: Add a proper url for your package's homepage here.
    homepage = "https://www.example.com"
    url      = "http://mvapich.cse.ohio-state.edu/download/mvapich/osu-micro-benchmarks-5.6.3.tar.gz"

    version('5.6.3', sha256='c5eaa8c5b086bde8514fa4cac345d66b397e02283bc06e44cb6402268a60aeb8')

    depends_on('openmpi')

    def configure_args(self):
        args = []
        args.append('CC={0}/bin/mpicc'.format(self.spec['openmpi'].prefix))
        args.append('CXX={0}/bin/mpicxx'.format(self.spec['openmpi'].prefix))
        return args


