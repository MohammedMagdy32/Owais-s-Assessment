variable "ami" {
  description = "The AMI ID for the EC2 instance"
  default     = "ami-0211c3296405e1021"  
}

variable "instance_type" {
  description = "The instance type for the EC2 instance"
  default     = "t2.micro"
}

variable "subnet_id" {
  description = "The ID of the subnet"
}

variable "security_group_ids" {
  description = "The IDs of the security groups"
  type        = list(string) # Ensure this is a list
}

variable "iam_instance_profile" {
  description = "The IAM instance profile"
}

