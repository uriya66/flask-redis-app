pipeline {
    agent any  // Run on any available agent

    environment {
        PROJECT_NAME = "flask-redis-app"
    }

    stages {
        stage('Preparation') {
            steps {
                script {
                    echo "Branch: ${env.GIT_BRANCH}"
                }
            }
        }

        stage('Dev Deploy') {
            when {
                branch 'dev'
            }
            steps {
                echo "Deploying Development version (port 8088)..."
                sh 'docker compose -f docker-compose.yml -f docker-compose.override.yml up --build -d'
            }
        }

        stage('Prod Deploy') {
            when {
                branch 'main'
            }
            steps {
                echo "Deploying Production version (port 8087)..."
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

