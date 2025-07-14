output "dr_vpc_id" {
  value = module.network.vpc_id
}

output "dr_ecs_cluster" {
  value = module.ecs.cluster_id
}

output "dr_ecs_service_name" {
  value = module.ecs.service_name
}

output "dr_rds_endpoint" {
  value = module.rds.db_endpoint
}

output "dr_alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "dr_alb_target_group_arn" {
  value = module.alb.target_group_arn
}

output "dr_alb_sg_id" {
  value = module.alb.alb_sg_id
}
