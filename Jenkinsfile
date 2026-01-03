pipeline {
    agent any
    
    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credential')
        DOCKER_IMAGE = 'cameljava/php-hello-world'
        DOCKER_TAG = "${env.BUILD_NUMBER}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build Docker Image with Buildah') {
            steps {
                script {
                    // Buildah build command (similar to docker build)
                    sh 
                    '''
                        buildah bud \
                            --tag ${DOCKER_IMAGE}:${IMAGE_TAG} \
                            --tag ${DOCKER_IMAGE}:latest \
                            -f Dockerfile \
                            .
                    '''
                }
            }
        }
        
        stage('Push Image') {
            steps {
                script {
                    // Use skopeo (included with Buildah) to push images
                    // Or use buildah push
                    sh 
                    '''
                        buildah push ${DOCKER_IMAGE}:${IMAGE_TAG} docker://${DOCKER_IMAGE}:${IMAGE_TAG}
                        buildah push ${DOCKER_IMAGE}:latest docker://${DOCKER_IMAGE}:latest
                    '''
                }
            }
        }
    }
   
    post {
        always {
            sh 'alias docker=podman&&docker logout'
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

