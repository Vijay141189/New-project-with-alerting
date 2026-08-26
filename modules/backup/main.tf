# -----------------------------------------------------------------------------
# Backup: a geo-redundant Recovery Services Vault (ready for VM/Files backup
# later) plus operational (point-in-time restore) backup for the storage
# account that holds property media and documents.
#
# Postgres and Redis backup/DR live inside their own modules
# (geo-redundant automated backups, HA, and the optional read replica) since
# those are properties of the resource itself, not a separate vault.
# -----------------------------------------------------------------------------

resource "azurerm_recovery_services_vault" "main" {
  name                = "rsv-${var.project_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  storage_mode_type           = "GeoRedundant"
  soft_delete_enabled         = true
  cross_region_restore_enabled = true

  tags = var.tags
}

# Data Protection vault backs Azure Storage blobs (recovery vault above
# doesn't support blob backup directly).
resource "azurerm_data_protection_backup_vault" "main" {
  name                = "bvault-${var.project_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  datastore_type      = "VaultStore"
  redundancy          = "GeoRedundant"

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

resource "azurerm_data_protection_backup_policy_blob_storage" "operational" {
  name               = "backup-policy-blob-${var.project_prefix}"
  vault_id           = azurerm_data_protection_backup_vault.main.id
  operational_default_retention_duration = "P30D"

  vault_default_retention_duration = "P30D"
  backup_repeating_time_intervals  = ["R/2026-01-01T00:00:00+00:00/P1W"]
}

# Grant the backup vault's managed identity what it needs to protect the
# storage account (blob backup contributor role).
resource "azurerm_role_assignment" "backup_storage_contributor" {
  scope                = var.storage_account_id
  role_definition_name = "Storage Account Backup Contributor"
  principal_id         = azurerm_data_protection_backup_vault.main.identity[0].principal_id
}

resource "azurerm_data_protection_backup_instance_blob_storage" "storage" {
  name               = "backup-${var.project_prefix}-storage"
  vault_id           = azurerm_data_protection_backup_vault.main.id
  location           = var.location
  storage_account_id = var.storage_account_id
  backup_policy_id   = azurerm_data_protection_backup_policy_blob_storage.operational.id

  depends_on = [azurerm_role_assignment.backup_storage_contributor]
}
