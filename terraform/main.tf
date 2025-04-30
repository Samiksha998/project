provider "aws" {
  region = "us-east-1"
}

# EC2 Instance
resource "aws_instance" "k8s_instance" {
  ami           = "ami-0b86aaed8ef90e45f"
  instance_type = "t2.medium"
  key_name      = "key"

  user_data = file("scripts/install-k8s.sh")

  tags = {
    Name = "k8s-instance"
  }
}

# Elastic IP - Associate existing EIP (must be manually allocated beforehand)
resource "aws_eip" "static_ip" {
  public_ip = "18.204.224.252"

  # Important: This requires the EIP to exist in your AWS account!
  depends_on = [aws_instance.k8s_instance]

  instance = aws_instance.k8s_instance.id
}

# Output for verification
output "instance_public_ip" {
  value = aws_instance.k8s_instance.public_ip
}
