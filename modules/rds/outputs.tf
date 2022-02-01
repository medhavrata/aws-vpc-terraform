output "sql_address" {
  value       = aws_db_instance.mysql_db.address
  description = "Connect to the database at this endpoint"
}

output "sql_port" {
  value       = aws_db_instance.mysql_db.port
  description = "The port the database is listening on"
}
