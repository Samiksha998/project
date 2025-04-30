pipeline {
    agent any

    environment {
        DOCKER_USERNAME = credentials('dockerhub-username') // Jenkins credentials ID
        DOCKER_PASSWORD = credentials('dockerhub-password')
        KUBECONFIG = "/home/ec2-user/.kube/config"
        FRONTEND_IMAGE = "yourdockerhubusername/frontend-app:latest"
        BACKEND_IMAGE = "yourdockerhubusername/backend-app:latest"
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/YOUR_GITHUB_REPO_URL.git', branch: 'main'
            }
        }

        stage('Build Docker Images') {
            steps {
                script {
                    sh '''
                    docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD

                    cd frontend
                    docker build -t $FRONTEND_IMAGE .
                    docker push $FRONTEND_IMAGE
                    cd ..

                    cd backend
                    docker build -t $BACKEND_IMAGE .
                    docker push $BACKEND_IMAGE
                    cd ..
                    '''
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                script {
                    sh '''
                    cd terraform
                    terraform init
                    terraform apply -auto-approve
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    sh '''
                    kubectl apply -f k8s/frontend-deployment.yaml
                    kubectl apply -f k8s/frontend-service.yaml
                    kubectl apply -f k8s/backend-deployment.yaml
                    kubectl apply -f k8s/backend-service.yaml
                    '''
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline completed."
        }
    }
}
