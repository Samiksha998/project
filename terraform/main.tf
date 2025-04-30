provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "k8s_instance" {
  ami           = "ami-0e449927258d45bc4" # Amazon Linux 2 AMI
  instance_type = "t2.xlarge"
  key_name      = "key"

  user_data = file("scripts/install-k8s.sh")

  tags = {
    Name = "k8s-instance"
  }
}

output "instance_public_ip" {
  value = aws_instance.k8s_instance.public_ip
}
