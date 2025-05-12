pipeline {
    agent any

    environment {
        PROJECT_NAME = "flask-redis-app"
    }

    stages {
        stage('Detect Git Context') {
            steps {
                script {
                    env.GIT_BRANCH = env.BRANCH_NAME ?: ""
                    env.IS_TAG = env.BRANCH_NAME ==~ /^v\d+\.\d+\.\d+$/ ? 'true' : 'false'
                    echo "🌿 BRANCH_NAME = ${env.GIT_BRANCH}"
                    echo "📦 IS_TAG = ${env.IS_TAG}"
                }
            }
        }

        stage('Dev Deploy') {
            when {
                expression { return env.GIT_BRANCH ==~ /.*dev$/ }
            }
            steps {
                echo "🚧 Starting Development Deploy on port 8087..."
                sh 'docker compose -f docker-compose.yml -f docker-compose.override.yml down || true'
                sh 'docker compose -f docker-compose.yml -f docker-compose.override.yml up --build -d'
            }
        }

        stage('Prod Deploy') {
            when {
                expression { return env.GIT_BRANCH == 'main' || env.IS_TAG == 'true' }
            }
            steps {
                echo "🚀 Starting Production Deploy on port 8088..."
                sh 'docker compose -f docker-compose.yml -f docker-compose.prod.yml down || true'
                sh 'docker compose -f docker-compose.yml -f docker-compose.prod.yml up --build -d'
            }
        }
    }

    post {
        success { echo "✅ Deployment completed successfully!" }
        failure { echo "❌ Deployment failed!" }
    }
}

