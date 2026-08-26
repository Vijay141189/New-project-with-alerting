output "primary_connection_string" {
  value       = azurerm_redis_cache.this.primary_connection_string
  description = "Primary connection string of the Redis cache"
  sensitive   = true
}

output "hostname" {
  value       = azurerm_redis_cache.this.hostname
  description = "Hostname of the Redis cache"
}

output "id" {
  value       = azurerm_redis_cache.this.id
  description = "Resource ID of the Redis cache"
}
