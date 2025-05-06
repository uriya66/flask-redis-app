pipeline {
    agent any

    environment {
        PROJECT_NAME = "flask-redis-app"
    }

    stages {
        stage('Preparation') {
            steps {
                script {
                    echo "Branch or Tag: ${env.GIT_BRANCH}" // Print the current branch or tag
                }
            }
        }

        stage('Dev Deploy') {
            when {
                expression { return env.GIT_BRANCH ==~ /.*dev$/ } // Run only on dev branch
            }
            steps {
                echo "Deploying Development version (port 8088)..."
                sh 'docker compose -f docker-compose.yml -f docker-compose.override.yml up --build -d'
            }
        }

        stage('Prod Deploy') {
            when {
                tag pattern: "v*", comparator: "REGEXP" // Run only on tag like v1.0.0
            }
            steps {
                echo "Deploying Production version (port 8087)..."
                sh 'docker compose -f docker-compose.yml -f docker-compose.prod.yml up --build -d'
            }
        }
    }

    post {
        success {
            echo "✅ Deployment completed successfully!" // Notify success
        }
        failure {
            echo "❌ Deployment failed!" // Notify failure
        }
    }
}

