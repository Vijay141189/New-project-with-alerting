output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

# Map of service name -> URL, one entry per backend microservice
output "backend_service_urls" {
  value = {
    for name, svc in module.backend_services :
    name => "https://${svc.default_hostname}"
  }
}

output "backend_service_staging_urls" {
  value = {
    for name, svc in module.backend_services :
    name => "https://${svc.staging_hostname}"
  }
}

output "frontend_url" {
  value = "https://${module.frontend.default_host_name}"
}

output "frontend_deployment_token" {
  value     = module.frontend.deployment_token
  sensitive = true
}

output "postgres_fqdn" {
  value = module.database.fqdn
}

output "redis_hostname" {
  value = module.cache.hostname
}

output "storage_account_name" {
  value = module.storage.account_name
}

output "storage_container_names" {
  value = module.storage.container_names
}

output "key_vault_name" {
  value = module.keyvault.vault_name
}

output "postgres_dr_replica_fqdn" {
  value       = module.database.replica_fqdn
  description = "FQDN of the cross-region PostgreSQL DR replica, if enabled"
}

output "recovery_services_vault_id" {
  value = module.backup.recovery_services_vault_id
}

output "log_analytics_workspace_id" {
  value = module.monitoring.log_analytics_workspace_id
}
