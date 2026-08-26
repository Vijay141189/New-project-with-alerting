resource "azurerm_linux_web_app" "this" {
  name                = "app-${var.project_prefix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = var.service_plan_id

  site_config {
    application_stack {
      node_version = var.node_version
    }
    always_on = true
  }

  app_settings = var.app_settings

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

resource "azurerm_linux_web_app_slot" "staging" {
  count = var.create_staging_slot ? 1 : 0

  name           = "staging"
  app_service_id = azurerm_linux_web_app.this.id

  site_config {
    application_stack {
      node_version = var.node_version
    }
  }

  tags = var.tags
}
