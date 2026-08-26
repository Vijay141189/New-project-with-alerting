environment = "staging"
location    = "centralindia"
dr_location = "southindia"

app_service_sku = "B1"

enable_delete_lock                = false
enable_ha                         = true
enable_dr_replica                 = false
keyvault_purge_protection_enabled = false
postgres_backup_retention_days    = 14
storage_replication_type          = "GRS"

monthly_budget_amount = 100
alert_emails           = []
