resource "aws_db_instance" "mysql_db" {
  identifier_prefix       = "mysql-id"
  engine                  = "mysql"
  allocated_storage       = 10
  instance_class          = "db.t2.micro"
  name                    = "mysql_database"
  username                = "mysqluser"
  multi_az                = var.multi_az
  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  skip_final_snapshot     = var.skip_final_snapshot
  publicly_accessible     = var.publicly_accessible
  db_subnet_group_name    = aws_db_subnet_group.mysql_rds_subnet.id
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]

  # How should we set the password?
  password = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["MyPassword"]
}


resource "aws_db_subnet_group" "mysql_rds_subnet" {
  name       = "main"
  subnet_ids = [for subnet in data.terraform_remote_state.network-config.outputs.private_subnets : subnet.id]

  tags = {
    Name = "My DB subnet group"
  }
}
