import groovy.transform.Field

@Field def job_base_name        = ""
@Field def project_name         = "bosa"
@Field def code_path            = ""
@Field def build_number         = ""
@Field def jenkins_server_name  = ""
@Field def branch_name          = ""

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
                //configMapVolume(mountPath: '/etc/docker', configMapName: 'docker-daemon-config')
        ]
) {
    try {
        node("docker-slave") {
            container("docker") {
                //sh "sleep 5m"
                stage('Project setup') {

                    //checking out the app code
                    echo 'Checkout the code..'
                    checkout scm
                    branch_name = env.BRANCH_NAME
                    build_number = env.BUILD_NUMBER
                    job_base_name = "${env.JOB_NAME}".split('/').last()
                    jenkins_server_name = env.BUILD_URL.split('/')[2].split(':')[0]
                    echo "Jenkins checkout from branch: $branch_name && $build_number"
                    echo "Running job ${job_base_name} on jenkins server ${jenkins_server_name}"
                    codePath = pwd()
                    sh "ls -lth"
                    sh '''
                                echo "nameserver 1.1.1.1" > /etc/resolv.conf
                                echo "nameserver 8.8.8.8" >> /etc/resolv.conf
                            
                    '''

                }
                withDockerRegistry([credentialsId: 'nexus-docker-registry', url: "https://nexus-group.bosa.belighted.com/"]) {

                    stage("Build test_runner") {
                        sh "docker login -u jenkins -p 'LB4AVhxy3^#JazJK' https://nexus-group.bosa.belighted.com/"
                        dir("ops/release/test_runner") {
                            echo "Start!"
                            //sh "sleep 5m"
                            //withDockerRegistry([credentialsId: 'nexus-docker-registry', url: "https://nexus-group.bosa.belighted.com/"]) {
                            sh "./build"
                            //}
                            echo "Done!"
                        }

                    }
                    stage("Compile Assets") {
                        sh """
                            docker run -e RAILS_ENV=production --env-file ${codePath}/ops/release/test_runner/app_env -v ${codePath}/public:/app/public bosa-testrunner:latest bundle exec rake assets:clean
                            docker run -e RAILS_ENV=production --env-file ${codePath}/ops/release/test_runner/app_env -v ${codePath}/public:/app/public bosa-testrunner:latest bundle exec rake assets:precompile
                        """

                    }
                    stage("Build app image"){
                        withDockerRegistry([credentialsId: 'nexus-docker-registry', url: "https://app.bosa.belighted.com/"]) {
                            withDockerRegistry([credentialsId: 'nexus-docker-registry', url: "https://assets.bosa.belighted.com/"]) {
                                switch (job_base_name) {
                                    case ~/^\d+\.\d+\.\d+$/:
                                        sh "TAG=$job_base_name ${codePath}/ops/release/app/build"
                                        sh "TAG=$job_base_name ${codePath}/ops/release/assets/build"
                                        break
                                    default:
                                        sh "TAG=$job_base_name-$build_number ${codePath}/ops/release/app/build"
                                        sh "TAG=$job_base_name-$build_number ${codePath}/ops/release/assets/build"
                                        break
                                }
                            }
                        }
                    }
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