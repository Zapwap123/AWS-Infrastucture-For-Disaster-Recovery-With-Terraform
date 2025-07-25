provider "aws" {
  region = var.primary_region
}

provider "aws" {
  alias  = "dr"
  region = var.dr_region
}

module "network" {
  source      = "./modules/network"
  vpc_name    = var.vpc_name
  cidr_block  = var.vpc_cidr
  azs         = var.azs
  environment = "dr"
  providers   = { aws = aws.dr }
}

module "ecs" {
  source             = "./modules/ecs"
  cluster_name       = var.ecs_cluster_name
  desired_count      = 0
  subnet_ids         = module.network.private_subnets
  ecs_task_exec_role = var.ecs_exec_role_arn
  log_group_name     = var.log_group_name
  image_uri          = var.image_uri
  secret_arns        = var.secret_arns
  region             = var.dr_region
  target_group_arn   = module.alb.target_group_arn
  security_groups    = [module.alb.alb_sg_id]
  depends_on         = [module.alb]
  listener_arn       = module.alb.listener_arn


  providers = {
    aws = aws.dr
  }
}


module "alb" {
  source         = "./modules/alb"
  alb_name       = var.alb_name
  vpc_id         = module.network.vpc_id
  public_subnets = module.network.public_subnets
  alb_sg_cidr    = var.alb_sg_cidr
  providers      = { aws = aws.dr }
}

module "rds" {
  source               = "./modules/rds"
  db_instance_id       = var.rds_replica_id
  source_db_identifier = var.source_rds_identifier
  instance_class       = var.db_instance_class
  subnet_ids           = module.network.private_subnets
  azs                  = var.azs
  providers            = { aws = aws.dr }
}

module "dr_trigger" {
  source                 = "./modules/dr_trigger"
  primary_alb_target_arn = var.primary_alb_target_arn
  dr_cluster_name        = var.ecs_cluster_name
  dr_service_name        = "${var.ecs_cluster_name}-service"
  dr_region              = var.dr_region
}