pipeline {
    agent any

    environment {
        DOCKER_USERNAME = credentials('samikshav')
        DOCKER_PASSWORD = credentials('Samiksha@1998')
        EC2_PUBLIC_IP = credentials('54.146.251.245')
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Samiksha998/project.git'
            }
        }
        stage('Docker Build & Push Frontend') {
            steps {
                sh """
                docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
                docker build -t $DOCKER_USERNAME/full-stack-app-frontend:latest ./docker/frontend
                docker push $DOCKER_USERNAME/full-stack-app-frontend:latest
                """
            }
        }
        stage('Docker Build & Push Backend') {
            steps {
                sh """
                docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
                docker build -t $DOCKER_USERNAME/full-stack-app-backend:latest ./docker/backend
                docker push $DOCKER_USERNAME/full-stack-app-backend:latest
                """
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                sh """
                ssh -o StrictHostKeyChecking=no ec2-user@3.235.135.218 << EOF
                  kubectl apply -f /home/ec2-user/project/k8s-manifests/
                EOF
                """
            }
        }
    }
}
