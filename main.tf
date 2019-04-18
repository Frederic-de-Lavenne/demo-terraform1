#define the provider and default region
provider "aws" {
  region = "eu-west-1"
}

#define s3 storage
terraform {
  backend "s3" {
    bucket = "fred-demo-tf-states"
    key    = "account-setup"
    region = "eu-west-1"
  }
}


#define private key type
resource "tls_private_key" "tf_key" {
  algorithm = "RSA"
}

#define ssh key pair
resource "aws_key_pair" "vms-key" {
  key_name   = "vms-key-demo"
  public_key = "${tls_private_key.tf_key.public_key_openssh}"
}

resource "aws_security_group" "allow_gitlab" {
  name        = "allow_gitlab"
  description = "Allow gitlab inbound traffic"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_http_https_ssh"
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_web" {
  name        = "allow_web"
  description = "Allow web inbound traffic"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_http_https"
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
