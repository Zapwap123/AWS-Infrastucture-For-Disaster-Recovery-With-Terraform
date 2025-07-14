variable "cluster_name" {
  type = string
}

variable "desired_count" {
  type = number
}

variable "subnet_ids" {
  type = list(string)
}

variable "ecs_task_exec_role" {
  type = string
}

variable "log_group_name" {
  type = string
}

variable "image_uri" {
  type = string
}

variable "secret_arns" {
  type = list(string)
}

variable "target_group_arn" {
  type        = string
  description = "Target Group ARN for ALB"
}

variable "security_groups" {
  type        = list(string)
  description = "Security groups for ECS tasks"
}

variable "region" {
  description = "Region used for ECS log driver"
  type        = string
}

variable "listener_arn" {
  type = string
}
