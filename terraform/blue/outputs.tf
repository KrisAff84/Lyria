output "ipv6" {
  description = "IPv6 of Lyria instance"
  value       = aws_instance.lyria.ipv6_addresses
}