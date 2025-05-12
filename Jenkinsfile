pipeline {
    agent any  // Run the pipeline on any available Jenkins agent

    environment {
        PROJECT_NAME = "flask-redis-app"  // Base name of the Docker image
        IMAGE_TAG = "latest"              // Will be dynamically overridden if a version tag is detected
    }

    stages {
        stage('Detect Git Context') {
            steps {
                script {
                    // Detect the current Git branch or tag
                    env.GIT_BRANCH = env.BRANCH_NAME ?: ""

                    // Check if it is a version tag (e.g., v1.0.1)
                    env.IS_TAG = env.GIT_BRANCH ==~ /^v\d+\.\d+\.\d+$/ ? 'true' : 'false'

                    // Assign the image tag based on tag or fallback to 'latest'
                    env.IMAGE_TAG = env.IS_TAG == 'true' ? env.GIT_BRANCH : "latest"

                    // Print detected values
                    echo "GIT_BRANCH = ${env.GIT_BRANCH}"
                    echo "IS_TAG = ${env.IS_TAG}"
                    echo "IMAGE_TAG = ${env.IMAGE_TAG}"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Build the Docker image with dynamic version tag and pass build arg to Dockerfile
                    echo "Building Docker image: ${PROJECT_NAME}:${IMAGE_TAG}"
                    sh """
                        docker build \
                        --build-arg BUILD_VERSION=${IMAGE_TAG} \
                        -t ${PROJECT_NAME}:${IMAGE_TAG} .
                    """
                }
            }
        }

        stage('Security Scan') {
            steps {
                script {
                    // Run a vulnerability scan using Snyk; do not fail pipeline on vulnerabilities
                    echo "Running security scan on image ${PROJECT_NAME}:${IMAGE_TAG}"
                    sh """
                        snyk test --docker ${PROJECT_NAME}:${IMAGE_TAG} || echo "Snyk scan completed with warnings"
                    """
                }
            }
        }

        stage('Dev Deploy') {
            when {
                // Run only if this is a dev branch
                expression { return env.GIT_BRANCH ==~ /.*dev$/ }
            }
            steps {
                // Stop existing containers in dev (ignore errors) and deploy dev stack
                echo "Starting Development Deploy on port 8087"
                sh 'docker compose -f docker-compose.yml -f docker-compose.override.yml down || true'
                sh 'docker compose -f docker-compose.yml -f docker-compose.override.yml up --build -d'
            }
        }

        stage('Prod Deploy') {
            when {
                // Run only on main or version tag
                expression { return env.GIT_BRANCH == 'main' || env.IS_TAG == 'true' }
            }
            steps {
                // Stop running production containers and deploy with proper image tag
                echo "Starting Production Deploy on port 8088"
                sh 'docker compose -f docker-compose.yml -f docker-compose.prod.yml down || true'
                sh "IMAGE_TAG=${IMAGE_TAG} docker compose -f docker-compose.yml -f docker-compose.prod.yml up --build -d"
            }
        }
    }

    post {
        success {
            // Run when the pipeline finishes successfully
            echo "Deployment completed successfully"
        }
        failure {
            // Run when the pipeline fails
            echo "Deployment failed"
        }
    }
}

