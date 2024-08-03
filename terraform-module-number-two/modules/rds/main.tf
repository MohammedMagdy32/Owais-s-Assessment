resource "aws_db_instance" "app_db" {
  allocated_storage    = var.allocated_storage
  engine               = "mysql"
  engine_version       = "5.7.44"
  instance_class       = var.instance_class
  identifier           = var.db_name
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  vpc_security_group_ids = var.security_group_ids
  db_subnet_group_name = aws_db_subnet_group.main.name

  tags = {
    Name = "app_db"
  }
}

resource "aws_db_subnet_group" "main" {
  name       = "main"
  subnet_ids = var.subnet_ids
  tags = {
    Name = "main"
  }
}

