data "aws_secretsmanager_secret" "db" {
  name = "FirstDatabasepassword"
}

data "aws_secretsmanager_secret_version" "secret_version" {
  secret_id = data.aws_secretsmanager_secret.db.id
}
