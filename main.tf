#----------------------------------------------------------
# Terraform -> OpenTofu
# Build WebServer on AWS EC2 during Bootstrap
#
# 1. terraform init
# 2. terraform apply
# 3. tofu init
# 4. tofu apply
#
# Copyleft (c) by Denis Astahov 2024
#----------------------------------------------------------

provider "aws" {
  region = "ca-central-1"
}

resource "aws_default_vpc" "default" {} 

resource "aws_instance" "web" {
  ami                         = "ami-07117708253546063" # Amazon Linux 2023
  instance_type               = "t3.micro"
  vpc_security_group_ids      = [aws_security_group.web.id]
  user_data_replace_on_change = true 
  user_data                   = <<EOF
#!/bin/bash
yum update -y
yum install nginx -y
systemctl start nginx
systemctl enable nginx
EOF

  tags = {
    Name  = "WebServer Built by Tofu/Terraform"
    Owner = "Denis Astahov"
  }
}

resource "aws_security_group" "web" {
  name        = "WebServer-SG"
  description = "Security Group for my WebServer"
  vpc_id      = aws_default_vpc.default.id 

  ingress {
    description = "Allow port HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow ALL ports"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "WebServer-SG"
    Owner = "Denis Astahov"
  }
}

output "ip" {
  value = aws_instance.web.public_ip
}