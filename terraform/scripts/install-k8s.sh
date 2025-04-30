#!/bin/bash

# Install K3s
curl -sfL https://get.k3s.io | sh -

# Wait for K3s service to start
sleep 15

# Copy kubeconfig to ec2-user's home and fix permissions
sudo cp /etc/rancher/k3s/k3s.yaml /home/ec2-user/kubeconfig.yaml
sudo chown ec2-user:ec2-user /home/ec2-user/kubeconfig.yaml
sudo chmod 600 /home/ec2-user/kubeconfig.yaml

# Export KUBECONFIG for current session
export KUBECONFIG=/home/ec2-user/kubeconfig.yaml

# Add to .bashrc for future sessions
echo 'export KUBECONFIG=~/kubeconfig.yaml' >> /home/ec2-user/.bashrc

# Verify K3s service
echo "Checking K3s service status..."
sudo systemctl status k3s | grep Active

# Wait a few seconds before running kubectl
sleep 5

# Check cluster info
echo "Kubernetes Cluster Info:"
/usr/local/bin/kubectl --kubeconfig=/home/ec2-user/kubeconfig.yaml cluster-info

# List nodes
echo "Listing Cluster Nodes:"
/usr/local/bin/kubectl --kubeconfig=/home/ec2-user/kubeconfig.yaml get nodes
