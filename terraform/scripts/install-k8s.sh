#!/bin/bash
# Install and configure Minikube on EC2

# Update system and install dependencies
sudo yum update -y
sudo yum install -y curl wget unzip bash-completion conntrack

# Install Docker
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker

# Add current user to docker group
sudo usermod -aG docker $USER && newgrp docker

# Download and install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Enable kubectl bash completion
kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null

# Install Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
rm minikube-linux-amd64

# Start Minikube with Docker driver
minikube start --driver=docker

# Enable Minikube dashboard (optional)
# minikube dashboard --url &

# Display status
minikube status
kubectl get nodes
