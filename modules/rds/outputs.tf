output "db_secret" {
  value = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["MyPassword"]
}
