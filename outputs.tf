output "vpc_id" {
  description = "ID of the security lab VPC"
  value       = aws_vpc.security_lab_vpc.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public_subnet.id
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.lab_sg.id
}

output "aws_region" {
  description = "AWS region deployed to"
  value       = var.aws_region
}
