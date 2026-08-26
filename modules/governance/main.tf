# -----------------------------------------------------------------------------
# Governance: tagging/location policy, resource-group lock, cost budget.
# Scope is the resource group so this stays additive and never touches
# subscription-level policy that other teams/projects might rely on.
# -----------------------------------------------------------------------------

# Enforce that every resource in the RG carries the mandatory tags.
resource "azurerm_resource_group_policy_assignment" "require_tags" {
  for_each = var.required_tag_names

  name                 = "require-tag-${each.value}"
  resource_group_id    = var.resource_group_id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/871b6d14-10aa-478d-b590-94f262ecfa99" # Require a tag on resources
  display_name         = "Require tag '${each.value}' on resources"

  parameters = jsonencode({
    tagName = { value = each.value }
  })
}

# Restrict which Azure regions resources can be created in (data residency / cost control).
resource "azurerm_resource_group_policy_assignment" "allowed_locations" {
  name                 = "allowed-locations"
  resource_group_id    = var.resource_group_id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c" # Allowed locations
  display_name         = "Restrict allowed deployment locations"

  parameters = jsonencode({
    listOfAllowedLocations = { value = var.allowed_locations }
  })
}

# Prevent accidental deletion of the whole environment in prod.
# Deliberately off by default (dev/staging) since it would also block
# `terraform destroy` for those environments during practice/teardown.
resource "azurerm_management_lock" "rg_lock" {
  count      = var.enable_delete_lock ? 1 : 0
  name       = "lock-${var.project_prefix}"
  scope      = var.resource_group_id
  lock_level = "CanNotDelete"
  notes      = "Managed by Terraform governance module - remove via 'terraform apply -var enable_delete_lock=false' before destroy."
}

# Monthly cost budget with email alerts at 80% (forecast) and 100% (actual).
resource "azurerm_consumption_budget_resource_group" "main" {
  count             = var.enable_budget ? 1 : 0
  name              = "budget-${var.project_prefix}"
  resource_group_id = var.resource_group_id

  amount     = var.monthly_budget_amount
  time_grain = "Monthly"

  time_period {
    start_date = var.budget_start_date
  }

  notification {
    enabled        = true
    threshold      = 80
    operator       = "GreaterThan"
    threshold_type = "Forecasted"
    contact_emails = var.budget_alert_emails
  }

  notification {
    enabled        = true
    threshold      = 100
    operator       = "GreaterThan"
    threshold_type = "Actual"
    contact_emails = var.budget_alert_emails
  }
}
