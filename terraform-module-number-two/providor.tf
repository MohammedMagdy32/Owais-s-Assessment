terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-mm"
    key            = "terraform/state"
    region         = "us-west-2"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}

