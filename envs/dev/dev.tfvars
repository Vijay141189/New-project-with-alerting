environment = "dev"
location    = "centralindia"
dr_location = "southindia"

app_service_sku = "B1"

enable_delete_lock                = false
enable_ha                         = false
enable_dr_replica                 = false
keyvault_purge_protection_enabled = false
postgres_backup_retention_days    = 7
storage_replication_type          = "LRS"

monthly_budget_amount = 50
alert_emails           = [vss141189@gmail.com]
