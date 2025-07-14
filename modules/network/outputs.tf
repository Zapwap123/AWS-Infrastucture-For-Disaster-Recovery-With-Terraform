output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.this.id
}

output "private_subnets" {
  description = "List of private subnet IDs"
  value       = values(aws_subnet.private)[*].id
}

output "public_subnets" {
  description = "Public subnets for ALB"
  value       = values(aws_subnet.public)[*].id
}

output "igw_id" {
  value = aws_internet_gateway.this.id
}
