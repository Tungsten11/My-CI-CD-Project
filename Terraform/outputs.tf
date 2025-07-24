output "instance_ip" {
    value = aws_instances.web.public_ip
}