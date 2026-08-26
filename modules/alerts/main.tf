# -----------------------------------------------------------------------------
# Wires every resource's logs/metrics into the shared Log Analytics workspace
# and adds a small set of metric alerts. Kept as its own module (rather than
# folded into `monitoring`) so it can depend on the resources it watches
# without creating a circular dependency: app services need
# monitoring.connection_string at creation time, so monitoring itself must
# not depend back on the app services.
# -----------------------------------------------------------------------------

resource "azurerm_monitor_diagnostic_setting" "targets" {
  for_each = var.diagnostic_targets

  name                       = "diag-${each.key}"
  target_resource_id         = each.value
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }

  metric {
    category = "AllMetrics"
  }
}

resource "azurerm_monitor_metric_alert" "app_service_5xx" {
  for_each = var.app_service_ids

  name                = "alert-5xx-${each.key}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value]
  description         = "Fires when ${each.key} returns server errors (5xx)."
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "Http5xx"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.error_count_threshold
  }

  action {
    action_group_id = var.action_group_id
  }

  tags = var.tags
}

resource "azurerm_monitor_metric_alert" "postgres_cpu" {
  name                = "alert-postgres-cpu-${var.project_prefix}"
  resource_group_name = var.resource_group_name
  scopes              = [var.postgres_id]
  description         = "Fires when PostgreSQL CPU stays above threshold."
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.DBforPostgreSQL/flexibleServers"
    metric_name      = "cpu_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.cpu_threshold_percent
  }

  action {
    action_group_id = var.action_group_id
  }

  tags = var.tags
}

resource "azurerm_monitor_metric_alert" "redis_memory" {
  name                = "alert-redis-memory-${var.project_prefix}"
  resource_group_name = var.resource_group_name
  scopes              = [var.redis_id]
  description         = "Fires when Redis used-memory percentage is high."
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.Cache/redis"
    metric_name      = "usedmemorypercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.memory_threshold_percent
  }

  action {
    action_group_id = var.action_group_id
  }

  tags = var.tags
}

resource "azurerm_monitor_metric_alert" "storage_availability" {
  name                = "alert-storage-availability-${var.project_prefix}"
  resource_group_name = var.resource_group_name
  scopes              = [var.storage_id]
  description         = "Fires when storage account availability drops below SLA."
  severity            = 1
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.Storage/storageAccounts"
    metric_name      = "Availability"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = var.availability_threshold_percent
  }

  action {
    action_group_id = var.action_group_id
  }

  tags = var.tags
}
