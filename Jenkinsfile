#!groovy

// Default quiet period for branches
Integer our_quiet_period = 6 * 3600;
if (env.CHANGE_ID != null) {
    // Pull Requests get default
    our_quiet_period = 60;
}

def isLegacyChange() {
  def target = false
  if (env.CHANGE_TARGET != null) {
    target = "refs/remotes/origin/${env.CHANGE_TARGET}"
  } else if (env.BRANCH_NAME != 'dev' && env.BRANCH_NAME != 'master') {
    target = sh(label: 'Retrieve merge base', returnStdout: true,
      script: "git merge-base refs/remotes/origin/dev HEAD").trim()
    print target
  }
  def changes = []
  if (target) {
    changes = sh(label: 'Retrieve list of changed files', returnStdout: true,
      script: "git diff --name-only ${target} HEAD").trim().split("\n")
    print changes.join('\n')

    for (change in changes) {
      if (change.contains('legacy') || change.startsWith('configure.sh')) {
        return true
      }
    }
  }
  return false
}

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
        def legacy = false
        try {
          checkout scm

          legacy = isLegacyChange() // needs to run after scm checkout in node context
          if (legacy) {
            ctestcmd = ctestcmd + ' -DBUILD_METHOD=legacy'
            container = container.replace('sif', 'legacy.sif')
          } else {
            ctestcmd = ctestcmd + ' -DBUILD_METHOD=spack'
          }

          if (node_type == 'slurm') {
            if (legacy) {
              ctestcmd = ctestcmd + ' -DNCPUS=\\\$SLURM_CPUS_PER_TASK'
            }
            sh(label: "Create Slurm Job Script", script: """
              exec test/slurm-create-jobscript.sh "${label}" "${container}" "${ctestcmd}" "${jobsh}"
            """)
          }

          callback.call(spec, label, jobsh, ctestcmd)

          githubNotify(context: title, description: 'Success', status: 'SUCCESS')
        } catch (e) {
          githubNotify(context: title, description: 'Error', status: 'ERROR')
          throw e
        } finally {
          if (legacy) {
            archiveArtifacts(artifacts: 'logs/**/*.log', allowEmptyArchive: true, fingerprint: true)
          }
        }
      }
    }
  }
  return nodes
}

pipeline {
  options {
    quietPeriod(our_quiet_period)
  }
  agent none
  stages {
    stage('Info Stage') {
      steps {
        echo "BRANCH_NAME: ${BRANCH_NAME}"
        echo "env.BRANCH_NAME: ${env.BRANCH_NAME}"
        echo "env.CHANGE_ID: ${env.CHANGE_ID}"
        echo "env.CHANGE_TARGET: ${env.CHANGE_TARGET}"
        echo "getBuildCauses: ${currentBuild.getBuildCauses()}"
        echo "our_quiet_period: ${our_quiet_period}"
      }
    }
    stage('Run CI Matrix') {
      steps{
        script {
          def ctestcmd = "ctest -VV -S FairSoft_test.cmake"
          def specs_list = [
            [os: 'Fedora32',         container: 'fedora.32.sif',    for_pr: true],
            [os: 'Ubuntu-18.04-LTS', container: 'ubuntu.18.04.sif'],
            [os: 'Ubuntu-20.04-LTS', container: 'ubuntu.20.04.sif', for_pr: true],
            [os: 'Debian-10',        container: 'debian.10.sif'],
            [os: 'GSI-Debian-8', container: 'gsi-debian-8.sif'],
            [os: 'openSUSE-15.2', container: 'opensuse.15.2.sif'],
          ]

          if (env.CHANGE_ID != null) {
              specs_list = specs_list.findAll {
                  elmt -> elmt.getOrDefault("for_pr", false)
              }
          }

          def linux_jobs = jobMatrix('slurm',
            ctestcmd + " -DUSE_TEMPDIR:BOOL=ON", specs_list
          ) { spec, label, jobsh, ctest ->
            sh(label: "Submit Slurm Job", script: """
              exec test/slurm-submit.sh "${label}" "${jobsh}"
            """)
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
          { spec, label, jobsh, ctest ->
            sh """
              hostname -f
              export LABEL=${label}
              ${ctest}
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

