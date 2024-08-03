provider "aws" {
  region = var.region
}

module "vpc" {
  source = "./modules/vpc"
  vpc_cidr = var.vpc_cidr
  subnet1_cidr = var.subnet1_cidr
  subnet2_cidr = var.subnet2_cidr
}

module "security_groups" {
  source      = "./modules/security_groups"
  vpc_id      = module.vpc.vpc_id
  subnet_cidr = var.subnet1_cidr
}

module "iam" {
  source = "./modules/iam"
}

module "ec2" {
  source               = "./modules/ec2"
  ami                  = var.ami
  instance_type        = var.instance_type
  subnet_id            = module.vpc.subnet1_id
  security_group_ids   = [module.security_groups.ec2_sg_id]
  iam_instance_profile = module.iam.ec2_instance_profile
}

module "rds" {
  source             = "./modules/rds"
  allocated_storage  = var.allocated_storage
  instance_class     = var.instance_class
  db_name            = var.db_name
  db_username        = var.db_username
  db_password        = var.db_password
  security_group_ids = [module.security_groups.rds_sg_id]
  subnet_ids         = [module.vpc.subnet1_id, module.vpc.subnet2_id]
}

