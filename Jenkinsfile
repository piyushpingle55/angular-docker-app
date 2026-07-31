pipeline {
    agent any

    environment {
        BUILD_IMAGE_NAME = "angular-builder:${BUILD_NUMBER}"
        DIST_OUTPUT_DIR  = "dist"
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Build inside Docker') {
            steps {
                script {
                    echo "--- Building Angular app inside isolated Docker container ---"
                    bat "docker build -t ${BUILD_IMAGE_NAME} ."
                }
            }
        }

        stage('Extract Dist Artifacts') {
            steps {
                script {
                    echo "--- Extracting compiled dist output ---"
                    // Delete existing dist folder if present
                    bat "if exist ${DIST_OUTPUT_DIR} rmdir /s /q ${DIST_OUTPUT_DIR}"
                    
                    bat "docker create --name temp-builder-${BUILD_NUMBER} ${BUILD_IMAGE_NAME}"
                    
                    // Adjust path below if your Dockerfile output path differs
                    bat "docker cp temp-builder-${BUILD_NUMBER}:/app/dist ${DIST_OUTPUT_DIR}"
                    
                    bat "docker rm -f temp-builder-${BUILD_NUMBER}"
                    bat "docker rmi -f ${BUILD_IMAGE_NAME}"
                }
            }
        }

        stage('Deploy via Ansible') {
            steps {
                script {
                    echo "--- Triggering Ansible deployment to IIS ---"
                    // Note: If running Ansible from Windows, ensure WSL or an Ansible runner is installed,
                    // or execute via PowerShell:
                    // bat "wsl ansible-playbook -i inventory/hosts deploy-iis.yml"
                }
            }
        }
    }

    post {
        always {
            // Cleanup container and image, suppressing errors if they don't exist
            bat "docker rm -f temp-builder-${BUILD_NUMBER} 2>nul || exit 0"
            bat "docker rmi -f ${BUILD_IMAGE_NAME} 2>nul || exit 0"
        }
    }
}