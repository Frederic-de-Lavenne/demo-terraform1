data "aws_route53_zone" "demo" {
  name = "as-a-code.info."
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners  = ["099720109477"]
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-20190212.1"]
  }
}

