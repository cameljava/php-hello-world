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
        
        stage('Build Docker Image') {
            steps {
                script {
                    sh """
                        docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
                        docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest
                    """
                }
            }
        }
        
        stage('Push to DockerHub') {
            steps {
                script {
                    sh """
                        echo ${DOCKERHUB_CREDENTIALS_PSW} | docker login -u ${DOCKERHUB_CREDENTIALS_USR} --password-stdin
                        docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                        docker push ${DOCKER_IMAGE}:latest
                    """
                }
            }
        }
    }
    
    post {
        always {
            sh 'docker logout'
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

