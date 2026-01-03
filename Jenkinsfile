pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'cameljava/php-hello-world'
        DOCKER_TAG   = "${BUILD_NUMBER}"
        CONTAINERS_STORAGE_CONF = "${WORKSPACE}/storage.conf"
        TMPDIR = "${WORKSPACE}/tmp"
    }

    stages {
        stage('Initialize Environment') {
            steps {
                sh '''
                    mkdir -p "$TMPDIR" "${WORKSPACE}/buildah-root" "${WORKSPACE}/buildah-runroot"

                    cat <<EOF > "$CONTAINERS_STORAGE_CONF"
[storage]
driver = "vfs"
runroot = "${WORKSPACE}/buildah-runroot"
graphroot = "${WORKSPACE}/buildah-root"

[storage.options.vfs]
ignore_chown_errors = "true"
EOF
                '''
            }
        }

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Image') {
            steps {
                sh '''
                    export BUILDAH_ISOLATION=chroot
                    buildah bud \
                        --tag ${DOCKER_IMAGE}:${DOCKER_TAG} \
                        --tag ${DOCKER_IMAGE}:latest \
                        -f Dockerfile .
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
                        buildah login -u "$DOCKERHUB_USER" -p "$DOCKERHUB_PASS" docker.io
                        buildah push ${DOCKER_IMAGE}:${DOCKER_TAG}
                        buildah push ${DOCKER_IMAGE}:latest
                    '''
                }
            }
        }
    }

    post {
        always {
            script {
                // Ensure we log out and clean up temporary storage files
                sh '''
                    # Logout from docker.io; || true ensures the script continues if not logged in
                    buildah logout docker.io || true
                    
                    # Clean up the workspace storage to prevent disk exhaustion
                    rm -rf "${WORKSPACE}/buildah-root" "${WORKSPACE}/buildah-runroot" "$TMPDIR"
                '''
            }
            cleanWs()
        }
    }
}