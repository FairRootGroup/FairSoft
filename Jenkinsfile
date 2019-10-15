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
          checkout scm

          sh """\
            echo "${env.SINGULARITY_CONTAINER_ROOT}/${spec.container} ctest -S FairSoft_test.cmake" >> job.sh
          """
          sh 'cat job.sh'

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
          def build_jobs = jobMatrix('build', [
            [os: 'Fedora30', container: 'fedora.30.sif'],
          ]) { spec, label ->
            sh "srun -p debug -c 8 -n 1 -t 15 bash job.sh"
          }
          parallel(build_jobs)
        }
      }
    }
  }
}

