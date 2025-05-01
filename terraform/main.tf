resource "aws_instance" "k8s_instance" {
  ami           = "ami-0b86aaed8ef90e45f" # Amazon Linux 2 AMI (region-specific)
  instance_type = "t2.medium"
  key_name      = "key" # Replace with your key name

  user_data = <<-EOF
              #!/bin/bash
              set -e
              curl -sfL https://get.k3s.io | sh -
              # Disable SELinux enforcement (to avoid k3s-selinux dependency issues)
              setenforce 0 || true
              # Install K3s without SELinux policies
              curl -sfL https://get.k3s.io | INSTALL_K3S_SKIP_SELINUX_RPM=true sh -
              # Copy kubeconfig to ec2-user home
              cp /etc/rancher/k3s/k3s.yaml /home/ec2-user/kubeconfig.yaml
              chown ec2-user:ec2-user /home/ec2-user/kubeconfig.yaml
              chmod 644 /home/ec2-user/kubeconfig.yaml
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
      private_key = file("${path.module}/key.pem") # Make sure this exists
      host        = aws_instance.k8s_instance.public_ip
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
