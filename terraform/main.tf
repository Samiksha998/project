provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "k8s_instance" {
  ami           = "ami-0b86aaed8ef90e45f"
  instance_type = "t2.medium"
  key_name      = "key"

  # Use this to ensure K3s is installed and kubeconfig is generated
  user_data = file("scripts/install-k8s.sh")

  tags = {
    Name = "k8s-instance"
  }

  provisioner "remote-exec" {
    inline = [
      "set -euo pipefail",
      "set -x",
      "echo 'Checking for kubeconfig.yaml on the EC2 instance...'",
      "retry=0; while [ ! -f /home/ec2-user/kubeconfig.yaml ]; do sleep 10; retry=$((retry+1)); echo \"Retry #$retry\"; if [ $retry -ge 12 ]; then echo 'Timeout waiting for kubeconfig'; exit 1; fi; done",
      "ls -l /home/ec2-user/kubeconfig.yaml"
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
