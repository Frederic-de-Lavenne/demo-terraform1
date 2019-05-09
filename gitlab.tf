#create an elastic IP
 resource "aws_eip" "demo-gitlab" {
   count = 1
   vpc   = true
 }

#associate eip to the ec2 instance
 resource "aws_eip_association" "eip_demo" {
   count         = 1
   instance_id   = "${aws_instance.demo-gitlab.id}"
   allocation_id = "${aws_eip.demo-gitlab.id}"
 }

#create a DNS entry in route 53 to associate with the ec2 instance
  resource "aws_route53_record" "A" {
    count   = 1
    zone_id = "${data.aws_route53_zone.demo.zone_id}"
    name    = "gitlab.as-a-code.info."
    type    = "A"
    ttl     = "300"
    records = ["${aws_eip.demo-gitlab.public_ip}"]
  }

#create the ec2 instance for the demo-gitlab

resource "aws_instance" "demo-gitlab" {
  count                  = 1
  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "t3.medium"
  key_name               = "${aws_key_pair.vms-key.key_name}"
  #subnet_id              = "${data.aws_subnet_ids.public.ids[1]}"
  vpc_security_group_ids = ["${aws_security_group.allow_gitlab.id}"]

  root_block_device {
    volume_type = "gp2"
    volume_size = 32
  }

  tags {
    Name = "Demo-Gitlab-Services"
  }

  provisioner "file" {
    source      = "demo-gitlab"
    destination = "/home/ubuntu"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${tls_private_key.tf_key.private_key_pem}"
    }
  }
  
  provisioner "remote-exec" {
    inline = [
      # set hostname  
      "sudo hostnamectl set-hostname gitlab",

      

      #retrieve gpg key for docker
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "sleep 10",
      "sudo systemd-run --property=\"After=apt-daily.service apt-daily-upgrade.service\" --wait /bin/true",

      # install docker
      "echo install docker",
      "sudo add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable' && sleep 10 && sudo apt-get update && sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -yq && sudo apt-get install -y docker-ce=5:18.09.2~3-0~ubuntu-bionic",
      
      "echo add docker on group ubuntu",
      "sudo usermod -aG docker ubuntu",

      "echo  install docker-compose",
      "sudo curl -L https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose",
      "sudo chmod a+x /usr/local/bin/docker-compose",
      
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${tls_private_key.tf_key.private_key_pem}"
    }
  }
  provisioner "remote-exec" {
   inline = [
     "cd ~/demo-gitlab",
     "echo strat container",
     "/usr/local/bin/docker-compose up -d ",
      
   ]
   connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${tls_private_key.tf_key.private_key_pem}"
    }
  }
}



