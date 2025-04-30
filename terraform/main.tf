provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "k8s_instance" {
  ami           = "ami-0b86aaed8ef90e45f"
  instance_type = "t2.medium"
  key_name      = "key"

  # Use this to ensure K3s is installed and kubeconfig is generated

  user_data = file("scripts/install-k3s.sh")

  tags = {
    Name = "k8s-instance"
  }

provisioner "remote-exec" {
  inline = [
    "set -euxo pipefail",

    "echo '📁 Checking for /home/ec2-user/kubeconfig.yaml...'",

    # Wait until kubeconfig.yaml exists or timeout after 12 retries (2 min)
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
  allocation_id = "eipalloc-030bfd53db39d9735" # Replace with your actual Allocation ID
}

output "instance_public_ip" {
  value = aws_instance.k8s_instance.public_ip
}
