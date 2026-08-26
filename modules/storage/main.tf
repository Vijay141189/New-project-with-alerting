resource "azurerm_storage_account" "main" {
  name                     = lower(substr("st${replace(var.project_prefix, "-", "")}", 0, 24))
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = var.replication_type
  min_tls_version          = "TLS1_2"

  # Backup/DR foundation: versioning + soft delete let us point-in-time
  # restore blobs (used by the operational backup policy in modules/backup),
  # and change_feed gives an audit trail of what changed and when.
  blob_properties {
    versioning_enabled  = true
    change_feed_enabled = true

    delete_retention_policy {
      days = var.blob_soft_delete_days
    }

    container_delete_retention_policy {
      days = var.blob_soft_delete_days
    }
  }

  tags = var.tags
}

resource "azurerm_storage_container" "containers" {
  for_each = var.containers

  name                  = each.key
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = each.value
}
