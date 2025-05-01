resource "aws_instance" "k8s_instance" {
  ami           = "ami-0b86aaed8ef90e45f"
  instance_type = "t2.medium"
  key_name      = "key"

  user_data = <<-EOF
              #!/bin/bash
              set -e

              echo "Disabling SELinux enforcement (if enabled)..."
              setenforce 0 || true

              echo "Installing K3s without SELinux dependencies..."
              curl -sfL https://get.k3s.io | INSTALL_K3S_SKIP_SELINUX_RPM=true sh -

              echo "Copying kubeconfig to user home..."
              cp /etc/rancher/k3s/k3s.yaml /home/ec2-user/kubeconfig.yaml
              chown ec2-user:ec2-user /home/ec2-user/kubeconfig.yaml
              chmod 644 /home/ec2-user/kubeconfig.yaml

              echo "✅ K3s installation and configuration complete."
              EOF

  tags = {
    Name = "k8s-instance"
  }

  provisioner "remote-exec" {
    inline = [
      "echo '📁 Checking for /home/ec2-user/kubeconfig.yaml...'",
      "retry=0; while [ ! -f /home/ec2-user/kubeconfig.yaml ]; do",
      "  echo \"⏳ kubeconfig.yaml not found, retry #$retry\"",
      "  sleep 10",
      "  retry=$((retry+1))",
      "  if [ $retry -ge 12 ]; then",
      "    echo '❌ Timeout waiting for kubeconfig.yaml';",
      "    sudo cat /var/log/cloud-init-output.log",
      "    exit 1",
      "  fi",
      "done",
      "echo '✅ kubeconfig.yaml is ready.'"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("${path.module}/key.pem")
      host        = aws_instance.k8s_instance.public_ip
    }
  }
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.k8s_instance.id
  allocation_id = "eipalloc-030bfd53db39d9735"
}

output "instance_public_ip" {
  value = aws_instance.k8s_instance.public_ip
}
