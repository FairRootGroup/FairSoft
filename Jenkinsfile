#!groovy

def specToLabel(Map spec) {
  return "${spec.os}"
}

def jobMatrix(String prefix, List specs, Closure callback) {
  def nodes = [:]
  for (spec in specs) {
    def label = specToLabel(spec)
    def jobsh = "job_${label}.sh"
    nodes["${prefix}/${label}"] = {
      node('slurm') {
        githubNotify(context: "${prefix}/${label}", description: 'Building ...', status: 'PENDING')
        try {
          checkout scm

          sh """
            echo '#! /bin/bash' >${jobsh}
            echo 'echo "*** Job started at: \$(date -R)"' >>${jobsh}
            echo 'echo "*** Job ID: \$SLURM_JOB_ID"' >>${jobsh}
            echo "source <(sed -e '/^#/d' -e '/^export/!s/^.*=/export &/' /etc/environment)" >>${jobsh}
            echo "export LABEL=${label}" >>${jobsh}
            echo "${env.SINGULARITY_CONTAINER_ROOT}/run_container ${spec.container} ctest -VV -S FairSoft_test.cmake" >> ${jobsh}
          """
          sh "cat ${jobsh}"

          callback.call(spec, label, jobsh)

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
            sh """ echo "*** Submitting at: \$(date -R)" """
            sh """srun -p main -c 64 -n 1 -t 300 --job-name="alfa-${label}" bash ${jobsh}"""
          }
          parallel(build_jobs)
        }
      }
    }
  }
}

