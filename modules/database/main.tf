resource "azurerm_postgresql_flexible_server" "this" {
  name                   = "psql-${var.project_prefix}"
  resource_group_name    = var.resource_group_name
  location               = var.location
  version                = "15"
  administrator_login    = var.admin_username
  administrator_password = var.admin_password
  sku_name               = "B_Standard_B1ms"
  storage_mb             = 32768
  zone                   = "1"

  # Backup / DR
  backup_retention_days       = var.backup_retention_days
  geo_redundant_backup_enabled = var.geo_redundant_backup_enabled

  dynamic "high_availability" {
    for_each = var.high_availability_enabled ? [1] : []
    content {
      mode                      = "ZoneRedundant"
      standby_availability_zone = var.standby_zone
    }
  }

  public_network_access_enabled = true

  tags = var.tags
}

# Optional cross-region read replica for disaster recovery. Promote it
# manually (or via a break-glass pipeline) if the primary region goes down.
# Requires geo_redundant_backup_enabled = false is NOT required, but the
# replica must live in a different region than the primary.
resource "azurerm_postgresql_flexible_server" "replica" {
  count = var.enable_dr_replica ? 1 : 0

  name                = "psql-${var.project_prefix}-dr"
  resource_group_name = var.resource_group_name
  location            = var.dr_location
  create_mode         = "Replica"
  source_server_id    = azurerm_postgresql_flexible_server.this.id

  tags = var.tags
}

# Allow other Azure services to connect (firewall rule)
resource "azurerm_postgresql_flexible_server_firewall_rule" "azure_services" {
  name             = "allow-azure-services"
  server_id        = azurerm_postgresql_flexible_server.this.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_postgresql_flexible_server_database" "this" {
  name      = "db_realestate"
  server_id = azurerm_postgresql_flexible_server.this.id
  collation = "en_US.utf8"
  charset   = "utf8"
}
