output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = aws_lb.this.dns_name
}

output "alb_sg_id" {
  description = "Security group ID of the ALB"
  value       = aws_security_group.alb_sg.id
}

output "target_group_arn" {
  description = "ARN of the target group used by the ALB"
  value       = aws_lb_target_group.this.arn
}
