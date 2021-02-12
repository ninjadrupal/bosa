podTemplate(
        label: 'docker-slave',
        containers: [
            containerTemplate(
                    name: 'docker',
                    image: 'docker:stable-dind',
                    ttyEnabled: true,
                    alwaysPullImage: true,
                    privileged: true,
                    command: 'dockerd --host=unix:///var/run/docker.sock --host=tcp://0.0.0.0:2375 --storage-driver=overlay2'
            )
        ],
        volumes: [
                emptyDirVolume(memory: false, mountPath: '/var/lib/docker')
        ]
) {
    try {
        node("docker-slave") {

            stage('Project setup') {

                    //checking out the app code
                    echo 'Checkout the code..'
                    checkout scm
                    branchName = env.BRANCH_NAME
                    buildNumber = env.BUILD_NUMBER
                    jobBaseName = "${env.JOB_NAME}".split('/').last() // We want to get the name of the branch/tag
                    jenkinsSrvName = env.BUILD_URL.split('/')[2].split(':')[0]
                    echo "Jenkins checkout from branch: $branchName && $buildNumber"
                    echo "Running job ${jobBaseName} on jenkins server ${jenkinsSrvName}"
                    codePath = pwd()
                    sh "ls -lth"

            }
            stage("Build test_runner"){
                dir("ops/release/test_runner") {
                    echo "Start!"
                    //sh "sleep 30m"
                    withDockerRegistry([credentialsId: 'nexus-docker-registry', url: "https://nexus-group.bosa.belighted.com/"]) {
                        sh "./build"
                    }
                    echo "Done!"
                }

            }
        }
    }
    catch (e) {
        // If there was an exception thrown, the build failed
        currentBuild.result = "FAILED"
        throw e
    }
}