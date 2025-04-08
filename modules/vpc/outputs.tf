output "vpc_id" {
  value       = aws_vpc.this.id
  description = "The VPC ID"
}

output "public_subnets" {
  value       = aws_subnet.public[*].id
  description = "IDs of the public subnets"
}

output "private_subnets" {
  value       = aws_subnet.private[*].id
  description = "IDs of the private subnets"
}
