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
  } else if (env.BRANCH_NAME =~ /legacy/) {
    return true
  } else if (env.BRANCH_NAME != 'dev' && env.BRANCH_NAME != 'master') {
    sh "git fetch --no-tags --force --progress -- ${scm.userRemoteConfigs[0].url} +refs/heads/dev:refs/remotes/origin/dev"
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

def jobMatrix(String node_type, String inp_ctestcmd, List specs, Closure callback) {
  def nodes = [:]
  for (spec in specs) {
    // allocate some fresh objects per loop iteration
    def ctestcmd = inp_ctestcmd
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
    def extra = spec.getOrDefault("extra", null)
    nodes[title] = {
      node(node_alloc_label) {
        githubNotify(context: title, description: 'Building ...', status: 'PENDING')
        def legacy = false
        try {
          checkout scm

          if (extra != null) {
            ctestcmd = ctestcmd + ' ' + extra
          }

          legacy = isLegacyChange() // needs to run after scm checkout in node context
          if (legacy) {
            ctestcmd = ctestcmd + ' -DBUILD_METHOD=legacy'
            container = container.replace('sif', 'legacy.sif')
          } else {
            ctestcmd = ctestcmd + ' -DBUILD_METHOD=spack'
          }

          if (node_type == 'slurm') {
            sh(label: "Create Slurm Job Script", script: """
              exec test/slurm-create-jobscript.sh "${label}" "${container}" "${jobsh}" ${ctestcmd}
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
        echo """
          env.BRANCH_NAME: ${env.BRANCH_NAME}
          env.CHANGE_ID: ${env.CHANGE_ID}
          env.CHANGE_TARGET: ${env.CHANGE_TARGET}
          env.GIT_PREVIOUS_COMMIT: ${env.GIT_PREVIOUS_COMMIT}
          env.GIT_PREVIOUS_SUCCESSFUL_COMMIT: ${env.GIT_PREVIOUS_SUCCESSFUL_COMMIT}
          """
        echo "getBuildCauses: ${currentBuild.getBuildCauses()}"
        echo "our_quiet_period: ${our_quiet_period}"
      }
    }
    stage('Run CI Matrix') {
      steps{
        script {
          def ctestcmd = "ctest -VV -S FairSoft_test.cmake"
          def specs_list = [
            [os: 'Almalinux-9',      container: 'almalinux.9.sif'],
            [os: 'Debian-10',        container: 'debian.10.sif'],
            [os: 'Debian-11',        container: 'debian.11.sif'],
            [os: 'Debian-12',        container: 'debian.12.sif'],
            [os: 'Fedora-37',        container: 'fedora.37.sif'],
            [os: 'Fedora-38',        container: 'fedora.38.sif'],
            [os: 'Fedora-39',        container: 'fedora.39.sif',
             extra: '-DCMAKE_CXX_STANDARD=20'],
            [os: 'Ubuntu-22.04-LTS', container: 'ubuntu.22.04.sif'],
            [os: 'Ubuntu-24.04-LTS', container: 'ubuntu.24.04.sif'],
          ]

          def linux_jobs = jobMatrix('slurm',
            ctestcmd + " -DUSE_TEMPDIR:BOOL=ON", specs_list
          ) { spec, label, jobsh, ctest ->
            sh(label: "Submit Slurm Job", script: """
              exec test/slurm-submit.sh "${label}" "${jobsh}"
            """)
          }

          specs_list = [
            [os: 'macos-13-x86_64'],
            [os: 'macos-14-x86_64'],
            [os: 'macos-14-arm64']
          ];

          def macos_jobs = jobMatrix('macos', ctestcmd, specs_list)
          { spec, label, jobsh, ctest ->
            sh """
              hostname -f
              export LABEL="${label}"
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

