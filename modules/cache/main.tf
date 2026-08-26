resource "azurerm_redis_cache" "this" {
  name                = "redis-${var.project_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  capacity            = 0
  family              = "C"
  sku_name            = "Basic"
  non_ssl_port_enabled = false
  minimum_tls_version = "1.2"
  tags                = var.tags
}
