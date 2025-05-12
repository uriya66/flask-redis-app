pipeline {
    agent any  // Use any available agent (Jenkins node)

    environment {
        PROJECT_NAME = "flask-redis-app"  // Name of the Docker image/project
        IMAGE_TAG = "latest"              // Default image tag, overridden later if a version tag is detected
    }

    stages {
        stage('Detect Git Context') {
            steps {
                script {
                    // Detect the current Git branch or tag
                    env.GIT_BRANCH = env.BRANCH_NAME ?: ""
                    
                    // Check if this is a version tag (e.g., v1.0.1)
                    env.IS_TAG = env.GIT_BRANCH ==~ /^v\d+\.\d+\.\d+$/ ? 'true' : 'false'

                    // If this is a tag, use it as IMAGE_TAG; otherwise, use "latest"
                    env.IMAGE_TAG = env.IS_TAG == 'true' ? env.GIT_BRANCH : "latest"

                    // Debug output
                    echo "🌿 BRANCH_NAME = ${env.GIT_BRANCH}"
                    echo "📦 IS_TAG = ${env.IS_TAG}"
                    echo "🏷️  IMAGE_TAG = ${env.IMAGE_TAG}"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Build the Docker image with the resolved IMAGE_TAG
                    echo "🔧 Building Docker image: ${PROJECT_NAME}:${IMAGE_TAG}"
                    sh "docker build -t ${PROJECT_NAME}:${IMAGE_TAG} ."
                }
            }
        }

        stage('Dev Deploy') {
            when {
                // Only run if the branch ends with 'dev'
                expression { return env.GIT_BRANCH ==~ /.*dev$/ }
            }
            steps {
                echo "🚧 Starting Development Deploy on port 8087..."

                // Stop previous containers if any (ignore failure)
                sh 'docker compose -f docker-compose.yml -f docker-compose.override.yml down || true'

                // Run development environment
                sh 'docker compose -f docker-compose.yml -f docker-compose.override.yml up --build -d'
            }
        }

        stage('Prod Deploy') {
            when {
                // Run only on 'main' branch or if this is a version tag
                expression { return env.GIT_BRANCH == 'main' || env.IS_TAG == 'true' }
            }
            steps {
                echo "🚀 Starting Production Deploy on port 8088..."

                // Stop production containers
                sh 'docker compose -f docker-compose.yml -f docker-compose.prod.yml down || true'

                // Run production containers with IMAGE_TAG passed as env var
                sh "IMAGE_TAG=${IMAGE_TAG} docker compose -f docker-compose.yml -f docker-compose.prod.yml up --build -d"
            }
        }
    }

    post {
        success {
            echo "✅ Deployment completed successfully!"
        }
        failure {
            echo "❌ Deployment failed!"
        }
    }
}

