output "delete_lock_enabled" {
  value       = var.enable_delete_lock
  description = "Whether the resource-group delete lock is active"
}

output "budget_name" {
  value       = var.enable_budget ? azurerm_consumption_budget_resource_group.main[0].name : null
  description = "Name of the consumption budget, if created"
}
