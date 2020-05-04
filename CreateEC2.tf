#provider block

provider "aws" {
  region     = "${var.region}"
}

#Create EC2 instance
resource "aws_instance" "ApacheInstanceByTerraform" {
  ami             = "${data.aws_ami.AmiForDemoApplication.id}"
  instance_type   = "${var.instance_type}"
  count = 1
  key_name = "MyEC2Instance-key-par"
  vpc_security_group_ids = [
      "${aws_security_group.webSG.id}",
  ]
  tags = {
    Name = "ApacheInstanceByTerraform"
  }

   connection {
    type = "ssh"
    user = "ec2-user"
    host = "${self.public_ip}"
    private_key = "${file("MyEC2Instance-key-par.pem")}"
  }


  
 
  #provisioners - remote-exec 
  provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd -y",
      "sudo systemctl start httpd",
      "sudo systemctl enable httpd",
      "sudo chmod 657 /var/www/html"
    ]
    
  }
  provisioner "file" {
    source      = "index.html"
    destination = "/var/www/html/index.html"

 }
 
  }



# data source - AMI
data "aws_ami" "AmiForDemoApplication" {
  most_recent = true
  owners = ["amazon"]

    filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.*"]
  }
}

#resources

#Create Security Group  
resource "aws_security_group" "webSG" {
  name        = "webSG"
  description = "Security group created by terraform"

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

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    
  }
}