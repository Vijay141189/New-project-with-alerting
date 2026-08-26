resource "azurerm_static_web_app" "this" {
  name                = "swa-${var.project_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_tier            = "Free"
  sku_size            = "Free"
  tags                = var.tags
}
