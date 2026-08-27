pipeline {
    agent any

    environment {
        FINAL_IMAGE_NAME = "angular-docker-app:latest"
        CONTAINER_NAME   = "angular-running-container"
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "--- Building Production Docker Image ---"
                    bat "docker build -t ${FINAL_IMAGE_NAME} ."
                }
            }
        }

        stage('Deploy Container') {
            steps {
                script {
                    echo "--- Redeploying Container on Port 8081 ---"
                    // Stop and remove existing container if running
                    bat "docker stop ${CONTAINER_NAME} 2>nul || exit 0"
                    bat "docker rm -f ${CONTAINER_NAME} 2>nul || exit 0"
                    
                    // Run fresh container mapped to host port 8081
                    bat "docker run -d -p 8081:80 --name ${CONTAINER_NAME} ${FINAL_IMAGE_NAME}"
                }
            }
        }
    }

    post {
        success {
            script {
                echo "======================================================="
                echo " SUCCESS! Access your app at: http://localhost:8081"
                echo "======================================================="
            }
        }
    }
}