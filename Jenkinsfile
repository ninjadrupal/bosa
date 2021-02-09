import groovy.transform.Field

@Field def app_branch_name = "master"
@Field def devops_branch_name = "master"

podTemplate(
        namespace: "devops-tools",
        containers: [
                containerTemplate(name: 'docker', image: 'docker:dind', ttyEnabled: true, privileged: true)
        ],
        envVars: [
                envVar(key: 'DOCKER_OPTS', value: '-H unix:// -H tcp://0.0.0.0:2375')
        ]

) {

    node(POD_LABEL) {
        stage('Git Clone') {
            dir("app/${project_name}") {
                //checking out the app code
                echo 'Checkout the code..'
                checkout scm
                branch_name = env.BRANCH_NAME
                build_number = env.BUILD_NUMBER
                job_base_name = "${env.JOB_NAME}".split('/').last() // We want to get the name of the branch/tag
                jenkins_server_name = env.BUILD_URL.split('/')[2].split(':')[0]
                echo "Jenkins checkout from branch: $branch_name && $build_number"
                echo "Running job ${job_base_name} on jenkins server ${jenkins_server_name}"
                code_path = pwd()
            }
            dir("devops"){
                git(
                        poll: true,
                        url: 'git@github.com:belighted/bosa-infrastructure-core.git',
                        credentialsId: 'vlad-github',
                        branch: "master"
                )
            }

            container('docker') {
                stage('Build a Docker project') {
                    dir("app/${project_name}"){
                        sh "ls -lth"
                        sh "pwd"
                        echo "Hello vlad!"
                    }
                }
            }
        }

    }
}