pipeline {
    agent any

    environment {
        DOCKER_USERNAME = credentials('samikshav')  // Credential ID: secret text or username
        DOCKER_PASSWORD = credentials('Samiksha@1998')  // Credential ID: secret text
        EC2_PUBLIC_IP   = '3.235.135.218'                 // Use IP directly unless you store it in credentials
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
                echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
                docker build -t $DOCKER_USERNAME/full-stack-app-frontend:latest ./docker/frontend
                docker push $DOCKER_USERNAME/full-stack-app-frontend:latest
                """
            }
        }

        stage('Docker Build & Push Backend') {
            steps {
                sh """
                echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
                docker build -t $DOCKER_USERNAME/full-stack-app-backend:latest ./docker/backend
                docker push $DOCKER_USERNAME/full-stack-app-backend:latest
                """
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sshagent (credentials: ['ec2-ssh-key']) { // Replace with your actual SSH key credential ID
                    sh """
                    ssh -o StrictHostKeyChecking=no ec2-user@$EC2_PUBLIC_IP '
                        kubectl apply -f /home/ec2-user/project/k8s-manifests/
                    '
                    """
                }
            }
        }
    }
}
