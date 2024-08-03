output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.app_instance.id
}

output "elastic_ip" {
  description = "The Elastic IP associated with the EC2 instance"
  value       = aws_eip.app_eip.public_ip
}

