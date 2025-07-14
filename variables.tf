variable "primary_region" {
  description = "Primary AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "dr_region" {
  description = "Disaster recovery region"
  type        = string
  default     = "eu-central-1"
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "azs" {
  description = "List of availability zones"
  type        = list(string)
}

variable "ecs_cluster_name" {
  description = "Name of the ECS Cluster"
  type        = string
}

variable "ecs_exec_role_arn" {
  description = "IAM role ARN for ECS task execution"
  type        = string
}

variable "log_group_name" {
  description = "CloudWatch Log Group name"
  type        = string
}

variable "image_uri" {
  description = "ECR image URI"
  type        = string
}

variable "secret_arns" {
  description = "List of secret ARNs for ECS task"
  type        = list(string)
}

variable "rds_replica_id" {
  description = "DB instance ID for the read replica"
  type        = string
}

variable "source_rds_identifier" {
  description = "Source RDS DB identifier in primary region"
  type        = string
}

variable "db_instance_class" {
  description = "DB instance class (e.g., db.t3.micro)"
  type        = string
}

variable "alb_name" {
  description = "Name of the ALB"
  type        = string
  default     = "ecs-lamp-dr-alb"
}

variable "alb_sg_cidr" {
  description = "CIDR allowed to access ALB (default is open)"
  type        = string
  default     = "0.0.0.0/0"
}

variable "desired_count" {
  type        = number
  description = "Desired count for ECS service"
}

variable "region" {
  type        = string
  description = "Region for logging/metrics (e.g., log driver)"
}

variable "primary_alb_target_arn" {
  type = string
}