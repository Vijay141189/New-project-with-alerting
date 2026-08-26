output "deployment_token" {
  value       = azurerm_static_web_app.this.api_key
  description = "Deployment token (API key) for the Static Web App"
  sensitive   = true
}

output "default_host_name" {
  value       = azurerm_static_web_app.this.default_host_name
  description = "Default host name of the Static Web App"
}
