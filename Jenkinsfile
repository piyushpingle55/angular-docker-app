pipeline {
    agent any

    environment {
        BUILD_IMAGE_NAME = "angular-builder:${BUILD_NUMBER}"
        FINAL_IMAGE_NAME = "angular-docker-app:latest"
        CONTAINER_NAME   = "angular-running-container"
        DIST_OUTPUT_DIR  = "dist"
        ZIP_FILE_NAME    = "angular-app-prod.zip"
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('SonarQube Code Quality Scan') {
            steps {
                script {
                    echo "--- Running SonarQube Static Code Analysis ---"
                    def scannerHome = tool 'SonarScanner'
                    withSonarQubeEnv('SonarQube') {
                        bat "${scannerHome}\\bin\\sonar-scanner.bat"
                    }
                }
            }
        }

        stage('Build inside Docker') {
            steps {
                script {
                    echo "--- Building intermediate builder stage ---"
                    bat "docker build --target build -t ${BUILD_IMAGE_NAME} ."
                }
            }
        }

        stage('Extract Dist Artifacts') {
            steps {
                script {
                    echo "--- Extracting dist files for zip artifact ---"
                    bat "if exist ${DIST_OUTPUT_DIR} rmdir /s /q ${DIST_OUTPUT_DIR}"
                    bat "if exist ${ZIP_FILE_NAME} del /f /q ${ZIP_FILE_NAME}"
                    
                    bat "docker create --name temp-builder-${BUILD_NUMBER} ${BUILD_IMAGE_NAME}"
                    bat "docker cp temp-builder-${BUILD_NUMBER}:/app/dist/angular-docker-app/browser ${DIST_OUTPUT_DIR}"
                    bat "docker rm -f temp-builder-${BUILD_NUMBER}"
                }
            }
        }

        stage('Create Production Zip Artifact') {
            steps {
                script {
                    echo "--- Zipping production build artifacts ---"
                    bat "powershell -Command \"Compress-Archive -Path '.\\${DIST_OUTPUT_DIR}\\*' -DestinationPath '.\\${ZIP_FILE_NAME}' -Force\""
                }
            }
        }

        stage('Archive Artifact in Jenkins') {
            steps {
                script {
                    echo "--- Saving ZIP file as a Jenkins build artifact ---"
                    archiveArtifacts artifacts: "${ZIP_FILE_NAME}", fingerprint: true
                }
            }
        }

        stage('Build Production Docker Image') {
            steps {
                script {
                    echo "--- Building full Nginx Docker Image ---"
                    // Full build without --target stop flag
                    bat "docker build --no-cache -t ${FINAL_IMAGE_NAME} ."
                }
            }
        }
       stage('Deploy to Kubernetes') {
    environment {
        // Points Jenkins to your personal user profile directories
        MINIKUBE_HOME = 'C:/Users/piyush'
        KUBECONFIG    = 'C:/Users/piyush/.kube/config'
    }
    steps {
        script {
            echo "--- Deploying to Local Kubernetes Cluster ---"
            
            // 1. Load the freshly built Docker image into Minikube
            bat "minikube image load ${FINAL_IMAGE_NAME}"
            
            // 2. Apply deployment and service configurations
            bat "kubectl apply -f k8s/deployment.yaml"
            bat "kubectl apply -f k8s/service.yaml"
            
            // 3. Trigger a zero-downtime rolling update
            bat "kubectl rollout restart deployment/angular-app-deployment"
        }
    }
}

        stage('Deploy to Port 8081') {
            steps {
                script {
                    echo "--- Redeploying container on port 8081 ---"
                    // Stop and remove old running container if it exists
                    bat "docker stop ${CONTAINER_NAME} 2>nul || exit 0"
                    bat "docker rm -f ${CONTAINER_NAME} 2>nul || exit 0"
                    
                    // Run new container with updated title changes
                    bat "docker run -d -p 8081:80 --name ${CONTAINER_NAME} ${FINAL_IMAGE_NAME}"
                }
            }
        }
    }

    post {
        always {
            script {
                // Clean up temporary build image only, keep FINAL_IMAGE_NAME intact
                bat "docker rm -f temp-builder-${BUILD_NUMBER} 2>nul || exit 0"
                bat "docker rmi -f ${BUILD_IMAGE_NAME} 2>nul || exit 0"
            }
        }
    }
}