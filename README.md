
# README

* prerequisites:
* * Have admin access to AWS   
* * The S3 bucket used for Terraform states must be created before using it   
* * Ensure to have the Terraform binary on your path /bin, you can download it at https://www.terraform.io/downloads.html   
* * Ensure to have an access key and secret key to use AWSCLI   
* * Ensure to have a recent version of AWSCLI https://aws.amazon.com/cli   
* * Chef will use self signed cert but you can put your own and gitlab will pull a let's encrypt certificate
   
      
On this workshop we will setup an ec2 instance running ubuntu 18   
we install docker and docker compose   
we setup a public elastic IP   
we launch a gitlab docker container   
   

We can access to gitlab on https://gitlab.as-a-code.info


