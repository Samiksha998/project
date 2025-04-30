#!/bin/bash

# Script to install K3s (lightweight Kubernetes) on Amazon Linux EC2

echo "🔄 Updating system..."
sudo yum update -y

echo "🔧 Installing dependencies..."
sudo yum install -y curl wget bash-completion

echo "🐳 Installing Docker..."
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

echo "🚀 Installing K3s..."
curl -sfL https://get.k3s.io | sh -

echo "✅ K3s Installed. Fetching status..."
sudo systemctl status k3s | grep Active

echo "🔍 Getting node status..."
sudo k3s kubectl get nodes

echo "📁 Saving kubeconfig to current user path: ~/k3s.yaml"
sudo cp /etc/rancher/k3s/k3s.yaml $HOME/k3s.yaml
sudo chown $(id -u):$(id -g) $HOME/k3s.yaml
echo "export KUBECONFIG=$HOME/k3s.yaml" >> ~/.bashrc
export KUBECONFIG=$HOME/k3s.yaml

echo "🧪 Verifying connection..."
kubectl get nodes

echo "✅ K3s setup completed successfully!"
