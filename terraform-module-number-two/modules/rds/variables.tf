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

variable "security_group_ids" {
  description = "The IDs of the security groups"
}

variable "subnet_ids" {
  description = "The IDs of the subnets"
}

