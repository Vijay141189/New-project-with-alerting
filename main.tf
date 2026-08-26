locals {
  prefix = "${var.project_name}-${var.environment}"
  tags   = merge(var.tags, { environment = var.environment })
}

resource "azurerm_resource_group" "main" {
  name     = "rg-${local.prefix}"
  location = var.location
  tags     = local.tags
}

module "governance" {
  source = "./modules/governance"

  project_prefix       = local.prefix
  resource_group_id    = azurerm_resource_group.main.id
  allowed_locations    = [var.location, var.dr_location]
  enable_delete_lock   = var.enable_delete_lock
  monthly_budget_amount = var.monthly_budget_amount
  budget_start_date    = "${formatdate("YYYY-MM-01", timestamp())}T00:00:00Z"
  budget_alert_emails  = var.alert_emails
}

module "monitoring" {
  source = "./modules/monitoring"

  project_prefix       = local.prefix
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  alert_emails         = var.alert_emails
  tags                 = local.tags
}

module "database" {
  source = "./modules/database"

  project_prefix               = local.prefix
  location                     = azurerm_resource_group.main.location
  resource_group_name          = azurerm_resource_group.main.name
  admin_username                = var.postgres_admin_username
  admin_password                = var.postgres_admin_password
  backup_retention_days         = var.postgres_backup_retention_days
  geo_redundant_backup_enabled  = true
  high_availability_enabled     = var.enable_ha
  enable_dr_replica             = var.enable_dr_replica
  dr_location                   = var.dr_location
  tags                          = local.tags
}

module "cache" {
  source = "./modules/cache"

  project_prefix       = local.prefix
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  tags                 = local.tags
}

module "storage" {
  source = "./modules/storage"

  project_prefix       = local.prefix
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  containers           = var.storage_containers
  replication_type     = var.storage_replication_type
  tags                 = local.tags
}

# Shared plan across all backend microservices - keeps cost down at small scale.
# Bump the SKU (or split into per-service plans) once traffic grows.
resource "azurerm_service_plan" "shared" {
  name                = "asp-${local.prefix}"
  resource_group_name = azurerm_resource_group.main.name
  location             = azurerm_resource_group.main.location
  os_type              = "Linux"
  sku_name             = var.app_service_sku
  tags                 = local.tags
}

# One App Service per backend microservice, generated from the
# backend_services map. Adding a new service = adding a map entry
# in variables.tf, not writing a new resource block.
module "backend_services" {
  source   = "./modules/app_service"
  for_each = var.backend_services

  project_prefix       = "${local.prefix}-${each.key}"
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  service_plan_id      = azurerm_service_plan.shared.id

  app_settings = {
    "SERVICE_NAME"                          = each.key
    "SERVICE_DESCRIPTION"                   = each.value.description
    "DATABASE_URL"                          = "postgresql://${var.postgres_admin_username}:${var.postgres_admin_password}@${module.database.fqdn}:5432/${module.database.database_name}?sslmode=require"
    "REDIS_CONNECTION_STRING"               = module.cache.primary_connection_string
    "STORAGE_CONNECTION_STRING"             = module.storage.primary_connection_string
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = module.monitoring.connection_string
  }

  tags = local.tags
}

module "frontend" {
  source = "./modules/frontend"

  project_prefix       = local.prefix
  resource_group_name  = azurerm_resource_group.main.name
  tags                 = local.tags
}

# Key Vault secrets, generated from a map so every sensitive value
# lands in the vault without one block per secret.
module "keyvault" {
  source = "./modules/keyvault"

  project_prefix            = local.prefix
  location                  = azurerm_resource_group.main.location
  resource_group_name       = azurerm_resource_group.main.name
  tenant_id                 = data.azurerm_client_config.current.tenant_id
  object_id                 = data.azurerm_client_config.current.object_id
  purge_protection_enabled  = var.keyvault_purge_protection_enabled

  secrets = {
    "postgres-admin-password"    = var.postgres_admin_password
    "storage-connection-string"  = module.storage.primary_connection_string
    "redis-connection-string"    = module.cache.primary_connection_string
    "frontend-deployment-token"  = module.frontend.deployment_token
  }

  tags = local.tags
}

# Grant each backend microservice's managed identity read access to the vault.
resource "azurerm_key_vault_access_policy" "backend_services" {
  for_each = var.backend_services

  key_vault_id = module.keyvault.vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = module.backend_services[each.key].principal_id

  secret_permissions = ["Get", "List"]
}

# -----------------------------------------------------------------------------
# Backup: geo-redundant Recovery Services Vault + operational blob backup.
# Depends on storage, so it's declared after it.
# -----------------------------------------------------------------------------
module "backup" {
  source = "./modules/backup"

  project_prefix       = local.prefix
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  storage_account_id   = module.storage.id
  tags                 = local.tags
}

# -----------------------------------------------------------------------------
# Alerts: diagnostic settings + metric alerts for every resource, wired to
# the shared Log Analytics workspace / action group from module.monitoring.
# Declared last since it depends on every other module's resource IDs.
# -----------------------------------------------------------------------------
module "alerts" {
  source = "./modules/alerts"

  project_prefix              = local.prefix
  resource_group_name         = azurerm_resource_group.main.name
  log_analytics_workspace_id  = module.monitoring.log_analytics_workspace_id
  action_group_id             = module.monitoring.action_group_id

  postgres_id = module.database.id
  redis_id    = module.cache.id
  storage_id  = module.storage.id

  app_service_ids = {
    for name, svc in module.backend_services : name => svc.id
  }

  diagnostic_targets = merge(
    { postgres = module.database.id },
    { redis    = module.cache.id },
    { storage  = module.storage.id },
    { keyvault = module.keyvault.vault_id },
    { for name, svc in module.backend_services : "app-${name}" => svc.id }
  )

  tags = local.tags
}
