#create an elastic IP
 resource "aws_eip" "demo-chef" {
   count = 1
   vpc   = true
 }

#associate eip to the ec2 instance
 resource "aws_eip_association" "eip_chef_demo" {
   count         = 1
   instance_id   = "${aws_instance.demo-chef.id}"
   allocation_id = "${aws_eip.demo-chef.id}"
 }

#create a DNS entry in route 53 to associate with the ec2 instance , so the website will be availlable at www.peach-staging.ebu.io
  resource "aws_route53_record" "chef" {
    count   = 1
    zone_id = "${data.aws_route53_zone.demo.zone_id}"
    name    = "chef.as-a-code.info."
    type    = "A"
    ttl     = "300"
    records = ["${aws_eip.demo-chef.public_ip}"]
  }

#create the ec2 instance for the demo-gitlab
variable "password" {}

#create the instance
resource "aws_instance" "demo-chef" {
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
    Name = "Demo-chef-Services"
  }
# install and configure chef server
  provisioner "remote-exec" {
    inline = [
      # set hostname  
      "sudo hostnamectl set-hostname chef.as-a-code.info",

      "cd /tmp",
      # download the chef server pkg for ubuntu 18
      "wget https://packages.chef.io/files/stable/chef-server/12.19.31/ubuntu/18.04/chef-server-core_12.19.31-1_amd64.deb",
      #this line to prevent a lock on apt or dpkg installation
      "sudo systemd-run --property=\"After=apt-daily.service apt-daily-upgrade.service\" --wait /bin/true",
      #install the chef server pkg
      "sudo dpkg -i chef-server-core_12.19.31-1_amd64.deb && sudo chef-server-ctl install chef-manage && sudo chef-server-ctl reconfigure && sudo chef-manage-ctl reconfigure --accept-license",
      #create an admin
      "sudo chef-server-ctl user-create fred frederic de Lavenne fred@delavenne.eu ${var.password} --filename /root/fred_private_key.pem",
      #create an organization
      "sudo chef-server-ctl org-create asacode 'demo infrastructure as a code' --association_user fred --filename /root/asacode_private_key.pem",
      
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${tls_private_key.tf_key.private_key_pem}"
    }
  }
  
}



