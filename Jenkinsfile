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

        stage('SonarQube Code Quality Scan') {
            steps {
                script {
                    echo "--- Running SonarQube Static Code Analysis ---"
                    
                    // Bind the SonarScanner tool installed in Jenkins
                    def scannerHome = tool 'SonarScanner'
                    
                    // Wrap with SonarQube Server configuration defined in Jenkins System
                    withSonarQubeEnv('SonarQube') {
                        // On Windows use 'bat', on Linux use 'sh'
                        bat "${scannerHome}\\bin\\sonar-scanner.bat"
                    }
                }
            }
        }

        stage('Build inside Docker') {
            steps {
                script {
                    echo "--- Building Angular app inside isolated Docker container ---"
                    bat "docker build --target build -t ${BUILD_IMAGE_NAME} ."
                }
            }
        }

        stage('Extract Dist Artifacts') {
            steps {
                script {
                    echo "--- Cleaning up previous builds and extracting dist ---"
                    bat "if exist ${DIST_OUTPUT_DIR} rmdir /s /q ${DIST_OUTPUT_DIR}"
                    bat "if exist ${ZIP_FILE_NAME} del /f /q ${ZIP_FILE_NAME}"
                    
                    bat "docker create --name temp-builder-${BUILD_NUMBER} ${BUILD_IMAGE_NAME}"
                    bat "docker cp temp-builder-${BUILD_NUMBER}:/app/dist/angular-docker-app/browser ${DIST_OUTPUT_DIR}"
                    
                    bat "docker rm -f temp-builder-${BUILD_NUMBER}"
                    bat "docker rmi -f ${BUILD_IMAGE_NAME}"
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
    }

    post {
        always {
            script {
                bat "docker rm -f temp-builder-${BUILD_NUMBER} 2>nul || exit 0"
                bat "docker rmi -f ${BUILD_IMAGE_NAME} 2>nul || exit 0"
            }
        }
    }
}