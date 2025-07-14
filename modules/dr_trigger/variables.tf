variable "primary_alb_target_arn" {
  description = "Target group ARN of the primary ALB"
  type        = string
}

variable "dr_cluster_name" {
  type = string
}

variable "dr_service_name" {
  type = string
}

variable "dr_region" {
  type = string
}
