#!groovy

def specToLabel(Map spec) {
  return "${spec.os}-${spec.arch}-${spec.compiler}-FairSoft_dev"
}

def jobMatrix(String prefix, List specs, Closure callback) {
  def nodes = [:]
  for (spec in specs) {
    def label = specToLabel(spec)
    def os = spec.os
    def compiler = spec.compiler
    nodes["${prefix}/${label}"] = {
      node(label) {
        githubNotify(context: "${prefix}/${label}", description: 'Building ...', status: 'PENDING')
        try {
          checkout scm

          if(fileExists('spack')) {
          } else {
            sh 'git clone https://github.com/FairRootGroup/spack.git'
          }

          REPO = sh(
                    script: './spack/bin/spack repo list | grep $WORKSPACE',
                    returnStdout: true
                   )
          if(REPO.contains('fairsoft')) {
          } else {
            sh './spack/bin/spack repo add $WORKSPACE'
          }

          sh './spack/bin/spack compilers'

          sh 'echo "#\n" > Dart.cfg'

          if (os =~ /Debian8/ && compiler =~ /gcc8/) {
            sh '''\
              echo "source /etc/profile.d/modules.sh" >> Dart.cfg
              echo "module use /cvmfs/it.gsi.de/modulefiles" >> Dart.cfg
              echo "module load compiler/gcc/8.1.0" >> Dart.cfg
              echo "export DDS_LD_LIBRARY_PATH=/cvmfs/it.gsi.de/compiler/gcc/8.1.0/lib64" >> Dart.cfg
            '''
          }

          sh '''\
            echo "export SPACK_DIR=$WORKSPACE/spack" >> Dart.cfg
            echo "export FAIRROOT_VERSION=18.2.1" >> Dart.cfg
            echo "export BUILDDIR=$PWD/build" >> Dart.cfg
            echo "export SOURCEDIR=$PWD" >> Dart.cfg
            echo "export GIT_BRANCH=$JOB_BASE_NAME" >> Dart.cfg
          '''
          sh 'cat Dart.cfg'

          callback.call(spec, label)

          githubNotify(context: "${prefix}/${label}", description: 'Success', status: 'SUCCESS')
        } catch (e) {
          githubNotify(context: "${prefix}/${label}", description: 'Error', status: 'ERROR')
          throw e
        }
      }
    }
  }
  return nodes
}


pipeline {
  agent none
  stages {
    stage("Run CI Matrix") {
      steps{
        script {
          def build_jobs = jobMatrix('alfa-ci/build', [
            [os: 'Debian8',    arch: 'x86_64', compiler: 'gcc8.1.0'],
            [os: 'MacOS10.13', arch: 'x86_64', compiler: 'AppleLLVM10.0.0'],
            [os: 'MacOS10.14', arch: 'x86_64', compiler: 'AppleLLVM10.0.0'],
          ]) { spec, label ->
            sh './Dart.sh Experimental Dart.cfg'
          }

          parallel(build_jobs)
        }
      }
    }
  }
}

