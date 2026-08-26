resource "azurerm_log_analytics_workspace" "this" {
  name                = "log-${var.project_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

resource "azurerm_application_insights" "this" {
  name                = "appi-${var.project_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.this.id
  application_type    = "web"
  tags                = var.tags
}

# Single action group used by every alert rule (app services, database,
# cache, storage). Kept here since it has no dependency on the resources
# being monitored, so it can't create a cycle with app_settings that
# reference module.monitoring.connection_string.
resource "azurerm_monitor_action_group" "main" {
  name                = "ag-${var.project_prefix}"
  resource_group_name = var.resource_group_name
  short_name          = substr(replace("${var.project_prefix}", "-", ""), 0, 12)

  dynamic "email_receiver" {
    for_each = var.alert_emails
    content {
      name          = "email-${email_receiver.key}"
      email_address = email_receiver.value
    }
  }

  tags = var.tags
}
