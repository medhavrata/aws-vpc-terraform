data "terraform_remote_state" "network-config" {
  backend = "s3"
  config = {
    bucket = "terraform-state-bucket-180122"
    key    = "network-config/terraform.tfstate"
    region = "us-east-1"
  }
}

data "aws_secretsmanager_secret" "db" {
  name = "FirstDatabasepassword"
}

data "aws_secretsmanager_secret_version" "secret_version" {
  secret_id = data.aws_secretsmanager_secret.db.id
}
