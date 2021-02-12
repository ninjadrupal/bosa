podTemplate(label: 'mypod', containers: [
        containerTemplate(name: 'docker', image: 'docker:dind', ttyEnabled: true, alwaysPullImage: true, privileged: true,
                command: 'dockerd --host=unix:///var/run/docker.sock --host=tcp://0.0.0.0:2375 --storage-driver=overlay')
],
        volumes: [emptyDirVolume(memory: false, mountPath: '/var/lib/docker')]) {

    node ('mypod') {
        stage 'Run a docker thing'
        container('docker') {
            stage 'Docker thing1'
            sh 'docker pull redis'
        }

    }
}