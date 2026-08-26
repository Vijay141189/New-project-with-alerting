environment = "prod"
location    = "centralindia"
dr_location = "southindia"

app_service_sku = "P1v3"

enable_delete_lock                = true
enable_ha                         = true
enable_dr_replica                 = true
keyvault_purge_protection_enabled = true
postgres_backup_retention_days    = 35
storage_replication_type          = "RAGRS"

monthly_budget_amount = 500
alert_emails           = ["oncall@example.com"]
