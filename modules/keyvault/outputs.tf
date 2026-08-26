output "vault_id" {
  value       = azurerm_key_vault.main.id
  description = "ID of the Key Vault"
}

output "vault_name" {
  value       = azurerm_key_vault.main.name
  description = "Name of the Key Vault"
}
