provider "aws" {
  region = "us-east-1"
}

resource "aws_default_vpc" "default" {
}

//http server -> SG
// SG -> 80 tcp, ssh 22 tcp, CIDR ["0.0.0.0/0"]

resource "aws_security_group" "http_server_sg" {
  name = "http_server_sg"
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

resource "aws_security_group" "elb_sg" {
  name = "elb_sg"
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
}

resource "aws_elb" "elb" {
  name = "elb"
  subnets = toset(data.aws_subnets.default_subnets.ids)
  security_groups = [aws_security_group.elb_sg.id]
  instances = values(aws_instance.http_servers).*.id
  
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}

resource "aws_instance" "http_servers" {
  //ami                    = "ami-06b09bfacae1453cb"
  ami                    = data.aws_ami.aws-linux-2-latest.id
  key_name               = "default-ec2"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.http_server_sg.id]
  //subnet_id              = "subnet-0352be171177c9e8c"

  for_each  = toset(data.aws_subnets.default_subnets.ids)
  subnet_id = each.value

  tags = {
    name : "http_servers_${each.value}"
  }

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