import groovy.transform.Field

@Field def job_base_name        = ""
@Field def project_name         = "bosa"
@Field def code_path            = ""
@Field def build_number         = ""
@Field def jenkins_server_name  = ""
@Field def branch_name          = ""
@Field def docker_assets_reg    = "assets.bosa.belighted.com"
@Field def docker_app_reg       = "app.bosa.belighted.com"
@Field def docker_img_group     = "nexus-group.bosa.belighted.com"

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
                sh "sleep 5m"
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
                withDockerRegistry([credentialsId: 'nexus-docker-registry', url: "https://${docker_img_group}/"]) {

                    stage("Build test_runner") {
                        dir("ops/release/test_runner") {
                            echo "Start!"
                            //sh "sleep 5m"
                            sh "./build"
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
                        switch (job_base_name){
                            case ~/^\d+\.\d+\.\d+$/:
                                    sh "TAG=$job_base_name ${codePath}/ops/release/app/build"
                                    sh "TAG=$job_base_name ${codePath}/ops/release/assets/build"
                                // This will push the assets image to registry
                                pushToNexus(
                                            "nexus-docker-registry",
                                            "https://${docker_assets_reg}/",
                                            "${docker_assets_reg}/bosa-assets:$job_base_name"
                                    )
                                // This will push the app image to registry
                                    pushToNexus(
                                            "nexus-docker-registry",
                                            "https://${docker_app_reg}/",
                                            "${docker_app_reg}/bosa:$job_base_name"
                                    )
                                break
                            default:
                                    sh "TAG=$job_base_name-$build_number ${codePath}/ops/release/app/build"
                                    sh "TAG=$job_base_name-$build_number ${codePath}/ops/release/assets/build"
                                // This will push the assets image to registry
                                pushToNexus(
                                            "nexus-docker-registry",
                                            "https://${docker_assets_reg}/",
                                            "${docker_assets_reg}/bosa-assets:${job_base_name}-${build_number}"
                                    )
                                // This will push the app image to registry
                                pushToNexus(
                                            "nexus-docker-registry",
                                            "https://${docker_app_reg}/",
                                            "${docker_app_reg}/bosa:${job_base_name}-${build_number}"
                                    )
                                break
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

def pushToNexus(String registryCredId, String registryUrl, String image){
    withDockerRegistry([credentialsId: registryCredId, url: registryUrl]) {
        sh "docker push ${image}"
    }
}