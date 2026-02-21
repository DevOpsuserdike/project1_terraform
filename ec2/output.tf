output "instance_id" {
  value = aws_instance.webapp.id
  description = "InstanceID"
}

output "public_ip" {
  value = aws_instance.webapp.public_ip
  description = "Public Ip address"
}


