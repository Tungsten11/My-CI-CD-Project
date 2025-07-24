provider "aws" {
    region = "ap-southeast-1" #region
}

resource "aws_instance" "web" {
    ami = ""
    instance_type = t2.micro
    key_name = "your-key-pair-name"


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



