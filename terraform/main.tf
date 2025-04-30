provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "k8s_instance" {
  ami           = "ami-0b86aaed8ef90e45f"
  instance_type = "t2.medium"
  key_name      = "key" # Replace with your EC2 key pair name

  user_data = <<-EOF
              #!/bin/bash

              # Enable full logging
              exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

              echo "🟢 Starting K3s installation..."

              # Install K3s
              curl -sfL https://get.k3s.io | sh -

              # Wait to ensure K3s service and kubeconfig are ready
              sleep 30

              echo "📁 Copying kubeconfig to ec2-user home..."
              sudo cp /etc/rancher/k3s/k3s.yaml /home/ec2-user/kubeconfig.yaml
              sudo chown ec2-user:ec2-user /home/ec2-user/kubeconfig.yaml
              sudo chmod 600 /home/ec2-user/kubeconfig.yaml

              # Export KUBECONFIG for current session and add to .bashrc
              echo 'export KUBECONFIG=~/kubeconfig.yaml' >> /home/ec2-user/.bashrc
              export KUBECONFIG=/home/ec2-user/kubeconfig.yaml

              echo "✅ kubeconfig.yaml is set and permissions applied."

              # Check K3s service status
              echo "🔍 Checking K3s service..."
              sudo systemctl status k3s | grep Active

              # Wait a few seconds before running kubectl
              sleep 5

              # Output cluster info
              echo "📡 Kubernetes Cluster Info:"
              /usr/local/bin/kubectl --kubeconfig=/home/ec2-user/kubeconfig.yaml cluster-info || echo "❌ Failed to get cluster info"

              # List nodes
              echo "🧩 Listing Kubernetes Nodes:"
              /usr/local/bin/kubectl --kubeconfig=/home/ec2-user/kubeconfig.yaml get nodes || echo "❌ Failed to list nodes"
              EOF

  tags = {
    Name = "k8s-instance"
  }

  provisioner "remote-exec" {
    inline = [
      "set -euxo pipefail",

      "echo '📁 Checking for /home/ec2-user/kubeconfig.yaml...'",

      "retry=0; while [ ! -f /home/ec2-user/kubeconfig.yaml ]; do",
      "  echo \"⏳ kubeconfig.yaml not found, retry #$retry\"",
      "  sleep 10",
      "  retry=$((retry+1))",
      "  if [ $retry -ge 12 ]; then",
      "    echo '❌ Timeout waiting for kubeconfig.yaml';",
      "    sudo cat /var/log/cloud-init-output.log || true",
      "    exit 1",
      "  fi",
      "done",

      "echo '✅ kubeconfig.yaml found. Listing file:'",
      "ls -lh /home/ec2-user/kubeconfig.yaml",

      "echo '📜 Preview of kubeconfig.yaml:'",
      "head -n 10 /home/ec2-user/kubeconfig.yaml || true"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("key.pem")
      host        = self.public_ip
    }
  }
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.k8s_instance.id
  allocation_id = "eipalloc-030bfd53db39d9735" # Replace with your EIP allocation ID
}

output "instance_public_ip" {
  value = aws_instance.k8s_instance.public_ip
}
