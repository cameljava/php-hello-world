pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'cameljava/php-hello-world'
        DOCKER_TAG   = "${BUILD_NUMBER}"
        BUILDAH_ISOLATION = 'chroot'
        STORAGE_DRIVER='vfs'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image with Buildah') {
            steps {
                sh '''
                    set -e

                    # Force writable locations for rootless Buildah
                    export HOME="$WORKSPACE"
                    export TMPDIR="$WORKSPACE/tmp"

                    mkdir -p \
                        "$TMPDIR" \
                        "$WORKSPACE/buildah-root" \
                        "$WORKSPACE/buildah-runroot"

                    buildah bud \
                        --isolation=chroot \
                        --storage-driver=vfs \
                        --root "$WORKSPACE/buildah-root" \
                        --runroot "$WORKSPACE/buildah-runroot" \
                        --tag ${DOCKER_IMAGE}:${DOCKER_TAG} \
                        --tag ${DOCKER_IMAGE}:latest \
                        -f Dockerfile \
                        .
                '''
            }
        }

        stage('Push Image') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-credential',
                        usernameVariable: 'DOCKERHUB_USER',
                        passwordVariable: 'DOCKERHUB_PASS'
                    )
                ]) {
                    sh '''
                        buildah login \
                          -u "$DOCKERHUB_USER" \
                          -p "$DOCKERHUB_PASS" \
                          docker.io

                        buildah push ${DOCKER_IMAGE}:${DOCKER_TAG}
                        buildah push ${DOCKER_IMAGE}:latest

                        buildah logout docker.io
                    '''
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success {
            echo "Docker image ${DOCKER_IMAGE}:${DOCKER_TAG} pushed successfully!"
        }
        failure {
            echo "Pipeline failed!"
        }
    }
}
