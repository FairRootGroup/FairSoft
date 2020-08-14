#!groovy

def jobMatrix(String node_type, String ctestcmd, List specs, Closure callback) {
  def nodes = [:]
  for (spec in specs) {
    def node_alloc_label = node_type
    def label = spec.os
    def jobsh = "job_${label}.sh"
    def title = "build/${label}"
    def container = ""
    if (node_type == 'macos') {
      node_alloc_label = label
    } else {
      container = spec.container
    }
    nodes[title] = {
      node(node_alloc_label) {
        githubNotify(context: title, description: 'Building ...', status: 'PENDING')
        try {
          checkout scm

          if (node_type == 'slurm') {
            sh """
              exec test/slurm-create-jobscript.sh "${label}" "${container}" "${ctestcmd}" "${jobsh}"
            """
          }

          callback.call(spec, label, jobsh)

          githubNotify(context: title, description: 'Success', status: 'SUCCESS')
        } catch (e) {
          githubNotify(context: title, description: 'Error', status: 'ERROR')
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
    stage('Run CI Matrix') {
      steps{
        script {
          def ctestcmd = "ctest -VV -S FairSoft_test.cmake"
          def specs_list = [
            [os: 'Fedora31',         container: 'fedora.31.sif',    for_pr: true],
            [os: 'Ubuntu-18.04-LTS', container: 'ubuntu.18.04.sif', for_pr: true],
            [os: 'Debian-10',        container: 'debian.10.sif'],
            [os: 'GSI-Debian-8', container: 'gsi-debian-8.sif'],
            [os: 'openSUSE-15.0', container: 'opensuse.15.0.sif'],
            [os: 'openSUSE-15.2', container: 'opensuse.15.2.sif'],
          ]

          if (env.CHANGE_ID != null) {
              specs_list = specs_list.findAll {
                  elmt -> elmt.getOrDefault("for_pr", false)
              }
          }

          def linux_jobs = jobMatrix('slurm',
            ctestcmd + " -DUSE_TEMPDIR:BOOL=ON", specs_list
          ) { spec, label, jobsh ->
            sh """
              exec test/slurm-submit.sh "${label}" "${jobsh}"
            """
          }

          if (env.CHANGE_ID != null) {
              specs_list = [
                [os: 'macOS'],
              ];
          } else {
              specs_list = [
                [os: 'macOS10.14'],
                [os: 'macOS10.15'],
              ];
          }

          def macos_jobs = jobMatrix('macos', ctestcmd, specs_list)
          { spec, label, jobsh ->
            sh """
              hostname -f
              export LABEL=${label}
              ${ctestcmd}
            """
          }
          throttle(['long']) {
            parallel(linux_jobs + macos_jobs)
          }
        }
      }
    }
  }
}

