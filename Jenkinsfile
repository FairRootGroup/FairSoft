#!groovy

def specToLabel(Map spec) {
  return "${spec.os}"
}

def jobMatrix(String prefix, List specs, Closure callback) {
  def nodes = [:]
  for (spec in specs) {
    def label = specToLabel(spec)
    nodes["${prefix}/${label}"] = {
      node('slurm') {
        githubNotify(context: "${prefix}/${label}", description: 'Building ...', status: 'PENDING')
        try {
          deleteDir()
          checkout scm

          sh """
            echo '#! /bin/bash' >job.sh
            echo "source <(sed -e '/^#/d' -e '/^export/!s/^/export /' /etc/environment)" >>job.sh
            echo "export LABEL=${label}" >>job.sh
            echo "${env.SINGULARITY_CONTAINER_ROOT}/run_container ${spec.container} ctest -VV -S FairSoft_test.cmake" >> job.sh
          """
          sh 'cat job.sh'

          callback.call(spec, label, "job.sh")

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
          def build_jobs = jobMatrix('build', [
            [os: 'Fedora30', container: 'fedora.30.sif'],
          ]) { spec, label, jobsh ->
            sh """srun -p main -c 8 -n 1 -t 300 --job-name="alfa-${label}" bash ${jobsh}"""
          }
          parallel(build_jobs)
        }
      }
    }
  }
}

