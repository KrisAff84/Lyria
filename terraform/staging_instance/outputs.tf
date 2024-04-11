output "staging_instance_ip" {
  value = aws_instance.staging_instance.public_ip
}

output "staging_instance_id" {
  value = aws_instance.staging_instance.id
}