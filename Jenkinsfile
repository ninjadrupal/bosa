import groovy.transform.Field

@Field def app_branch_name           = "master"
@Field def devops_branch_name        = "master"
@Field def project_name              = "bosa"
@Field def nexus_assets_registry_url = "assets.bosa.belighted.com"
@Field def nexus_app_registry_url    = "app.bosa.belighted.com"
@Field def nexus_credentials_id      = "nexus-docker-registry"

podTemplate(label: 'jenkins-pipeline', containers: [
        containerTemplate(name: 'jnlp', image: 'jenkins/inbound-agent:4.3-4', args: '${computer.jnlpmac} ${computer.name}', workingDir: '/home/jenkins', resourceRequestCpu: '500m', resourceLimitCpu: '500m', resourceRequestMemory: '1024Mi', resourceLimitMemory: '1024Mi'),
        containerTemplate(name: 'docker', image: 'docker:stable-dind', command: 'cat', ttyEnabled: true),
        containerTemplate(name: 'kubectl', image: 'lachlanevenson/k8s-kubectl:v1.8.3', command: 'cat', ttyEnabled: true)
        ],
        volumes:[
                hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock'),
        ]
) {
    node('jenkins-pipeline') {
        stage('Git Clone') {
            container('docker') {
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
                dir("app/${project_name}"){
                    stage('Build test_runner') {
                        withDockerRegistry([credentialsId: "${nexus_credentials_id}", url: 'https://nexus-group.bosa.belighted.com/']) {
                            sh """
                          
                                DOCKER_HOST=tcp://docker:2376 docker info
                                """
                            sh "$code_path/ops/release/test_runner/build"
                        }
                    }
                    stage("Compile assets"){
                        sh "docker run -e RAILS_ENV=production --env-file $PWD/ops/release/test_runner/app_env -v $PWD/public:/app/public bosa-testrunner:latest bundle exec rake assets:clean"
                        sh "docker run -e RAILS_ENV=production --env-file $PWD/ops/release/test_runner/app_env -v $PWD/public:/app/public bosa-testrunner:latest bundle exec rake assets:precompile"
                    }
                    stage("Build&Push images"){
                        switch (job_base_name){
                            case ~/^\d+\.\d+\.\d+$/:
                                withCredentials([usernamePassword(credentialsId: "${nexus_credentials_id}", usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                                    sh """
                                        docker login -u=$DOCKER_USERNAME -p=$DOCKER_PASSWORD base.bosa.belighted.com
                                        docker login -u=$DOCKER_USERNAME -p=$DOCKER_PASSWORD assets.bosa.belighted.com
                                        docker login -u=$DOCKER_USERNAME -p=$DOCKER_PASSWORD app.bosa.belighted.com
                                        """
                                    sh "TAG=$job_base_name-$build_number $code_path/ops/release/app/build"
                                    sh "TAG=$job_base_name-$build_number $code_path/ops/release/assets/build"
                                }
                                break
                            default:
                                withCredentials([usernamePassword(credentialsId: "${nexus_credentials_id}", usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                                    sh """
                                        ls -lth
                                        docker login -u=$DOCKER_USERNAME -p=$DOCKER_PASSWORD base.bosa.belighted.com
                                        docker login -u=$DOCKER_USERNAME -p=$DOCKER_PASSWORD assets.bosa.belighted.com
                                        docker login -u=$DOCKER_USERNAME -p=$DOCKER_PASSWORD app.bosa.belighted.com
                                        """
                                    sh "TAG=$job_base_name-$build_number $code_path/ops/release/app/build"
                                    sh "TAG=$job_base_name-$build_number $code_path/ops/release/assets/build"
                                }
                                break
                        }
                    }
                    stage("Deploy to K8s"){
                        echo "TBD"
                    }
                }
            }
        }

    }
}