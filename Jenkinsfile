podTemplate(label: 'mypod', containers: [
        containerTemplate(name: 'docker', image: 'docker:dind', ttyEnabled: true, alwaysPullImage: true, privileged: true,
                command: 'dockerd --host=unix:///var/run/docker.sock --host=tcp://0.0.0.0:2375 --storage-driver=overlay2')
],
        volumes: [emptyDirVolume(memory: false, mountPath: '/var/lib/docker')]) {

    node ('mypod') {
        stage 'Run a docker thing'
        container('docker') {
            stage 'Docker thing1'
            sh 'docker pull redis'
            sh """
                echo "FROM alpine:3.12" > Dockerfile
                echo "RUN apk add update" >> Dockerfile
                echo "RUN apk add vim" >> Dockerfile
                ls -lth
                docker build -t test:0.1.0 .
       
            """
        }

    }
}