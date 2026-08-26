output "primary_connection_string" {
  value       = azurerm_storage_account.main.primary_connection_string
  description = "Primary connection string of the storage account"
  sensitive   = true
}

output "account_name" {
  value       = azurerm_storage_account.main.name
  description = "Name of the storage account"
}

output "container_names" {
  value       = [for c in azurerm_storage_container.containers : c.name]
  description = "Names of the storage containers"
}

output "id" {
  value       = azurerm_storage_account.main.id
  description = "Resource ID of the storage account"
}
