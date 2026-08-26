output "recovery_services_vault_id" {
  value       = azurerm_recovery_services_vault.main.id
  description = "ID of the geo-redundant Recovery Services Vault"
}

output "backup_vault_id" {
  value       = azurerm_data_protection_backup_vault.main.id
  description = "ID of the Data Protection backup vault protecting blob storage"
}
