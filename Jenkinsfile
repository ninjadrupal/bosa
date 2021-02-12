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
    node ('docker-slave') {
        stage 'Run a docker thing'
        container('docker') {
            stage 'Docker thing1'
            sh 'docker pull redis'
            sh """
                echo "FROM alpine:3.12" > Dockerfile
                echo "RUN apk add vim zip" >> Dockerfile
                ls -lth
                docker build -t test:0.1.0 .
            """
        }

    }

    try {
        node("docker-slave") {

            stage('Project setup') {
                dir("app/bosa") {
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
            }
        }
    }
    catch (e) {
        // If there was an exception thrown, the build failed
        currentBuild.result = "FAILED"
        slackNotifyBuild("PIPELINE FAILED")
        throw e
    }
}