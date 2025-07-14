variable "alb_name" {
  type        = string
  description = "Name for the ALB and related resources"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "public_subnets" {
  type        = list(string)
  description = "List of public subnet IDs for ALB"
}

variable "alb_sg_cidr" {
  type        = string
  description = "CIDR block for ALB ingress rules"
  default     = "0.0.0.0/0"
}
