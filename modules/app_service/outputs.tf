output "default_hostname" {
  value       = azurerm_linux_web_app.this.default_hostname
  description = "Default hostname of the App Service"
}

output "staging_hostname" {
  value       = var.create_staging_slot ? azurerm_linux_web_app_slot.staging[0].default_hostname : null
  description = "Default hostname of the staging slot"
}

output "principal_id" {
  value       = azurerm_linux_web_app.this.identity[0].principal_id
  description = "Principal ID of the App Service's system-assigned managed identity"
}

output "id" {
  value       = azurerm_linux_web_app.this.id
  description = "Resource ID of the App Service"
}
