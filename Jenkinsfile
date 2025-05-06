pipeline {
    agent any

    environment {
        PROJECT_NAME = "flask-redis-app" // Define the project name
    }

    stages {
        stage('Detect Environment') {
            steps {
                script {
                    // Detect if this build was triggered by a Git tag
                    def describe = sh(script: "git describe --tags --exact-match || true", returnStdout: true).trim()
                    if (describe.startsWith("v")) {
                        env.GIT_TAG = describe
                        echo "Detected Tag: ${env.GIT_TAG}"
                    } else {
                        def branch = sh(script: "git rev-parse --abbrev-ref HEAD", returnStdout: true).trim()
                        env.GIT_BRANCH = branch
                        echo "Detected Branch: ${env.GIT_BRANCH}"
                    }
                }
            }
        }

        stage('Dev Deploy') {
            when {
                expression { return env.GIT_BRANCH ==~ /.*dev$/ } // Run only for branch ending in 'dev'
            }
            steps {
                echo "Deploying Development version (port 8088)..."
                sh 'docker compose -f docker-compose.yml -f docker-compose.override.yml down || true'
                sh 'docker compose -f docker-compose.yml -f docker-compose.override.yml up --build -d'
            }
        }

        stage('Prod Deploy') {
            when {
                expression { return env.GIT_TAG ==~ /^v.*/ } // Run only for tags like v1.0.0
            }
            steps {
                echo "Deploying Production version (port 8087)..."
                sh 'docker compose -f docker-compose.yml -f docker-compose.prod.yml down || true'
                sh 'docker compose -f docker-compose.yml -f docker-compose.prod.yml up --build -d'
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

