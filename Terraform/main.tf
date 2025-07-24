provider "aws" {
    region = "ap-southeast-1" #region
}

resource "aws_instance" "web" {
    ami = "ami-0062e0576ebcaa2a9"
    instance_type = t2.micro
    key_name = "my-cicd-app-key"

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

resource "aws_s3_bucket" "app_logs" {
    bucket = "my-flask-app-logs-${random.id.suffix.hex}"
    

    tags = {
        Name = "flask-app-logs"
    }
}

resource "random_id" "suffix" {
    byte_length = 4
}





