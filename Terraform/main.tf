provider "aws" {
    region = "ap-southeast-1" #region
}

# Get the default VPC
data "aws_vpc" "default" {
  default = true
}

# Create Security Group
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = data.aws_vpc.default.id
  

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
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "web" {
    ami = "ami-0062e0576ebcaa2a9"
    instance_type = "t2.micro"
    key_name = "my-cicd-app-key"
    vpc_security_group_ids = [aws_security_group.web_sg.id]

    user_data = <<-EOF
            #!/bin/bash
            yum update -y
            amazon-linux-extras install docker -y
            service docker start
            usermod -a -G docker ec2-user
            docker run -d -p 80:80 seeker1/flaskapp:latest
            EOF

    tags = {
        Name = "flask-docker-app" 
    }
}

resource "aws_cloudwatch_log_group" "flask_logs" {
    name = "/aws/ec2/flaskapp"
    retention_in_days = 7
}

resource "random_id" "suffix" {
    byte_length = 4

}
resource "aws_s3_bucket" "app_logs" {
    bucket = "my-flask-app-logs-${random_id.suffix.hex}"
    
    tags = {
        Name = "flask-app-logs"
    }
}








