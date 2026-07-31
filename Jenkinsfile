pipeline {
    agent any

    environment {
        BUILD_IMAGE_NAME = "angular-builder:${BUILD_NUMBER}"
        DIST_OUTPUT_DIR  = "./dist"
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
                    sh "docker build -t ${BUILD_IMAGE_NAME} ."
                }
            }
        }

        stage('Extract Dist Artifacts') {
            steps {
                script {
                    echo "--- Extracting compiled dist output ---"
                    sh "rm -rf ${DIST_OUTPUT_DIR}"
                    sh "docker create --name temp-builder-${BUILD_NUMBER} ${BUILD_IMAGE_NAME}"
                    // Adjust path below if your dist folder structure differs
                    sh "docker cp temp-builder-${BUILD_NUMBER}:/app/dist ${DIST_OUTPUT_DIR}"
                    sh "docker rm -f temp-builder-${BUILD_NUMBER}"
                    sh "docker rmi -f ${BUILD_IMAGE_NAME}"
                }
            }
        }

        stage('Deploy via Ansible') {
            steps {
                script {
                    echo "--- Triggering Ansible deployment to IIS ---"
                    // Update this path to your actual Ansible playbook location
                    // sh "ansible-playbook -i inventory/hosts deploy-iis.yml"
                }
            }
        }
    }

    post {
        always {
            sh "docker rm -f temp-builder-${BUILD_NUMBER} || true"
            sh "docker rmi -f ${BUILD_IMAGE_NAME} || true"
        }
    }
}