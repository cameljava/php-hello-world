pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'cameljava/php-hello-world'
        DOCKER_TAG   = "${BUILD_NUMBER}"
        DOCKER_BUILDKIT = '1'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Setup Buildx Builder') {
            steps {
                sh '''
                    set -e

                    # Create a user-space builder (idempotent)
                    if ! docker buildx inspect mybuilder >/dev/null 2>&1; then
                        docker buildx create --name mybuilder --use
                    else
                        docker buildx use mybuilder
                    fi
                '''
            }
        }

        stage('Build and Push Image') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-credential',
                        usernameVariable: 'DOCKERHUB_USER',
                        passwordVariable: 'DOCKERHUB_PASS'
                    )
                ]) {
                    sh '''
                        set -e

                        # Login to Docker Hub
                        docker login -u "$DOCKERHUB_USER" -p "$DOCKERHUB_PASS"

                        # Build and push the image with BuildKit / buildx
                        docker buildx build \
                            --builder mybuilder \
                            --platform linux/amd64 \
                            --tag ${DOCKER_IMAGE}:${DOCKER_TAG} \
                            --tag ${DOCKER_IMAGE}:latest \
                            --push \
                            -f Dockerfile .
                    '''
                }
            }
        }
    }

    post {
        always {
            sh '''
                # Logout from Docker Hub
                docker logout || true
            '''
            cleanWs()
        }
        success {
            echo "✅ Image ${DOCKER_IMAGE}:${DOCKER_TAG} pushed successfully!"
        }
        failure {
            echo "❌ Pipeline failed!"
        }
    }
}
