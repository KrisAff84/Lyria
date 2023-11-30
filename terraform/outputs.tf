output "elb_dns_name" {
  description = "DNS name of the ELB"
  value       = aws_lb.elb.dns_name
}

output "bastion_ip" {
  description = "Public IP of the bastion host"
  value       = aws_instance.bastion.public_ip
}

output "bastion_instance_id" {
  description = "Instance ID of the bastion host"
  value       = aws_instance.bastion.id
}