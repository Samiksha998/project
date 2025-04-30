provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "k8s_instance" {
  ami           = "ami-0b86aaed8ef90e45f"
  instance_type = "t2.medium"
  key_name      = "key"

  user_data = file("scripts/install-k8s.sh")

  tags = {
    Name = "k8s-instance"
  }
}

# Associate an existing Elastic IP
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.k8s_instance.id
  allocation_id = "eipalloc-030bfd53db39d9735"  # <-- Replace this with your actual Allocation ID
}

output "instance_public_ip" {
  value = aws_instance.k8s_instance.public_ip
}
