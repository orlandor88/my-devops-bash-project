provider "aws" {
  region = var.region
}

resource "tls_private_key" "generated_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "my-key"
  public_key = tls_private_key.generated_key.public_key_openssh
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ec2_instance" {
  ami                         = "ami-0a87a69d69fa289be" # Ubuntu 22.04 în Frankfurt
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.generated_key.key_name
  vpc_security_group_ids      = [aws_security_group.allow_ssh.id]

  provisioner "remote-exec" {
    inline = ["sudo apt update", "sudo apt install -y curl"]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.generated_key.private_key_pem
      host        = self.public_ip
    }
  }

  tags = {
    Name = "devops-bash-instance"
  }
}
