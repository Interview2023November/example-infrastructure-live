output "address" {
  value       = module.database_server.address
  description = "The DB address for connections."
}

output "port" {
  value       = module.database_server.port
  description = "The DB port for connections."
}

output "db_instance_id" {
  value       = module.database_server.db_instance_id
  description = "The instance ID of the database server."
}

output "db_username" {
  value       = random_string.username.result
  description = "The username for the database server."
  sensitive   = true
}

output "db_password" {
  value       = random_password.password.result
  description = "The password for the database server."
  sensitive   = true
}

output "db_security_group_id" {
  value       = aws_security_group.db.id
  description = "The ID of the database security group."
}
