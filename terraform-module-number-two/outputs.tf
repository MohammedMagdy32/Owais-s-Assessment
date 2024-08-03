output "vpc_id" {
  value = module.vpc.vpc_id
}

output "subnet1_id" {
  value = module.vpc.subnet1_id
}

output "subnet2_id" {
  value = module.vpc.subnet2_id
}

output "ec2_sg_id" {
  value = module.security_groups.ec2_sg_id
}

output "rds_sg_id" {
  value = module.security_groups.rds_sg_id
}

output "ec2_instance_profile" {
  value = module.iam.ec2_instance_profile
}

output "instance_id" {
  value = module.ec2.instance_id
}

output "rds_endpoint" {
  value = module.rds.endpoint
}

