output "fqdn" {
  value       = azurerm_postgresql_flexible_server.this.fqdn
  description = "FQDN of the PostgreSQL Flexible Server"
}

output "database_name" {
  value       = azurerm_postgresql_flexible_server_database.this.name
  description = "Name of the PostgreSQL database"
}

output "id" {
  value       = azurerm_postgresql_flexible_server.this.id
  description = "Resource ID of the PostgreSQL Flexible Server"
}

output "replica_fqdn" {
  value       = var.enable_dr_replica ? azurerm_postgresql_flexible_server.replica[0].fqdn : null
  description = "FQDN of the DR read replica, if created"
}
