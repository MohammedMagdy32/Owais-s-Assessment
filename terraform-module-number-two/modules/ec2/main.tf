resource "aws_instance" "app_instance" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  iam_instance_profile   = var.iam_instance_profile

  tags = {
    Name = "app_instance"
  }
}

resource "aws_eip" "app_eip" {
  instance = aws_instance.app_instance.id
}

