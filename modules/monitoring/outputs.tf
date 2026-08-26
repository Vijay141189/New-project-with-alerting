output "connection_string" {
  value       = azurerm_application_insights.this.connection_string
  description = "Connection string for Application Insights"
  sensitive   = true
}

output "log_analytics_workspace_id" {
  value       = azurerm_log_analytics_workspace.this.id
  description = "ID of the Log Analytics workspace"
}

output "action_group_id" {
  value       = azurerm_monitor_action_group.main.id
  description = "ID of the shared Monitor action group"
}
