variable "aws_key_pair" {
  default = "~/aws/aws_keys/default-ec2.pem"
}
provider "aws" {
  region = "us-east-1"
}

resource "aws_default_vpc" "default" {
  
}

data "aws_subnets" "default_subnets" {
  filter {
    name   = "vpc-id"
    values = [aws_default_vpc.default.id]
  }
}

data "aws_ami" "aws-linux-2-latest" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["amzn2-ami-kernel-5.10-hvm*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

data "aws_ami_ids" "aws-linux-2-latest_ids" {
  owners = ["amazon"]
}

//http server -> SG
// SG -> 80 tcp, ssh 22 tcp, CIDR ["0.0.0.0/0"]

resource "aws_security_group" "http_server_sg" {
  name   = "http_server_sg"
  //vpc_id = "vpc-074c4e3e073ac4874"
  vpc_id = aws_default_vpc.default.id
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name = "http_server_sg"
  }
}

resource "aws_instance" "http_server" {
  //ami                    = "ami-06b09bfacae1453cb"
  ami                    = data.aws_ami.aws-linux-2-latest.id
  key_name               = "default-ec2"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.http_server_sg.id]
  //subnet_id              = "subnet-0352be171177c9e8c"
  subnet_id              = data.aws_subnets.default_subnets.ids[0]
  
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file(var.aws_key_pair)
  }

  provisioner "remote-exec" {
    inline = [
      //install http
      "sudo yum install httpd -y",
      //start
      "sudo service httpd start",
      //copy a file
      "echo Welcome to Martut - Virtual Server is at ${self.public_dns} | sudo tee /var/www/html/index.html"
    ]
  }
}