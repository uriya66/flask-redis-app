pipeline {
    agent any

    environment {
        PROJECT_NAME = "flask-redis-app" // Project name for context
        GIT_BRANCH = ''
        GIT_TAG = ''
    }

    stages {
        stage('Detect Git Context') {
            steps {
                script {
                    // Detect Git tag (if any)
                    def tag = sh(script: "git describe --tags --exact-match || true", returnStdout: true).trim()
                    if (tag.startsWith("v")) {
                        env.GIT_TAG = tag
                        echo "📦 Detected Tag: ${env.GIT_TAG}"
                    }

                    // Always detect current branch
                    def branch = sh(script: "git rev-parse --abbrev-ref HEAD", returnStdout: true).trim()
                    env.GIT_BRANCH = branch
                    echo "🌿 Detected Branch: ${env.GIT_BRANCH}"
                }
            }
        }

        stage('Dev Deploy') {
            when {
                expression {
                    return env.GIT_BRANCH ==~ /.*dev$/ // Run only on branches like 'dev'
                }
            }
            steps {
                echo "🚧 Starting Development Deploy on port 8088..."
                sh 'docker compose -f docker-compose.yml -f docker-compose.override.yml down || true'
                sh 'docker compose -f docker-compose.yml -f docker-compose.override.yml up --build -d'
            }
        }

        stage('Prod Deploy') {
            when {
                allOf {
                    expression { return env.GIT_BRANCH == 'main' }  // Must be main
                    expression { return env.GIT_TAG ==~ /^v.*/ }     // Must be version tag
                }
            }
            steps {
                echo "🚀 Starting Production Deploy on port 8087..."
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

