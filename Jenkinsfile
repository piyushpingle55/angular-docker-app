pipeline {
    agent any

    environment {
        BUILD_IMAGE_NAME = "angular-builder:${BUILD_NUMBER}"
        DIST_OUTPUT_DIR  = "dist"
        ZIP_FILE_NAME    = "angular-app-prod.zip"
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
                    // Target the 'build' stage so intermediate dist files exist
                    bat "docker build --target build -t ${BUILD_IMAGE_NAME} ."
                }
            }
        }

        stage('Extract Dist Artifacts') {
            steps {
                script {
                    echo "--- Cleaning up previous builds and extracting dist ---"
                    // Remove old dist directory and zip file if they exist
                    bat "if exist ${DIST_OUTPUT_DIR} rmdir /s /q ${DIST_OUTPUT_DIR}"
                    bat "if exist ${ZIP_FILE_NAME} del /f /q ${ZIP_FILE_NAME}"
                    
                    // Create temporary container from build image
                    bat "docker create --name temp-builder-${BUILD_NUMBER} ${BUILD_IMAGE_NAME}"
                    
                    // Copy compiled Angular production browser assets
                    bat "docker cp temp-builder-${BUILD_NUMBER}:/app/dist/angular-docker-app/browser ${DIST_OUTPUT_DIR}"
                    
                    // Remove temporary container and build image
                    bat "docker rm -f temp-builder-${BUILD_NUMBER}"
                    bat "docker rmi -f ${BUILD_IMAGE_NAME}"
                }
            }
        }

        stage('Create Production Zip Artifact') {
            steps {
                script {
                    echo "--- Zipping production build artifacts ---"
                    // Compress dist directory contents into a ZIP file using PowerShell
                    bat "powershell -Command \"Compress-Archive -Path '.\\${DIST_OUTPUT_DIR}\\*' -DestinationPath '.\\${ZIP_FILE_NAME}' -Force\""
                }
            }
        }

        stage('Archive Artifact in Jenkins') {
            steps {
                script {
                    echo "--- Saving ZIP file as a Jenkins build artifact ---"
                    // Save the generated zip file in Jenkins artifact storage
                    archiveArtifacts artifacts: "${ZIP_FILE_NAME}", fingerprint: true
                }
            }
        }
    }

    post {
        always {
            script {
                // Ensure temporary containers/images are cleaned up even if build fails
                bat "docker rm -f temp-builder-${BUILD_NUMBER} 2>nul || exit 0"
                bat "docker rmi -f ${BUILD_IMAGE_NAME} 2>nul || exit 0"
            }
        }
    }
}