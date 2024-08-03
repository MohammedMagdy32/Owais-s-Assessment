variable "region" {
  description = "The AWS region to create resources in"
  default     = "us-west-2"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "subnet1_cidr" {
  description = "The CIDR block for the first subnet"
  default     = "10.0.1.0/24"
}

variable "subnet2_cidr" {
  description = "The CIDR block for the second subnet"
  default     = "10.0.2.0/24"
}

variable "ami" {
  description = "The AMI ID for the EC2 instance"
  default     = "ami-0211c3296405e1021"
}

variable "instance_type" {
  description = "The instance type for the EC2 instance"
  default     = "t2.micro"
}

variable "allocated_storage" {
  description = "The allocated storage for the RDS instance"
  default     = 20
}

variable "instance_class" {
  description = "The instance class for the RDS instance"
  default     = "db.m5.large"
}

variable "db_name" {
  description = "The name of the database"
  default     = "app-db"
}

variable "db_username" {
  description = "The username for the RDS instance"
  default     = "admin"
}

variable "db_password" {
  description = "The password for the RDS instance"
  default     = "password"
}

