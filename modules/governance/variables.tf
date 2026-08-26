variable "project_prefix" {
  type        = string
  description = "Project name and environment prefix"
}

variable "resource_group_id" {
  type        = string
  description = "ID of the resource group to govern"
}

variable "required_tag_names" {
  type        = set(string)
  description = "Tag keys that must be present on every resource in the RG"
  default     = ["project", "environment", "managedBy"]
}

variable "allowed_locations" {
  type        = list(string)
  description = "Azure regions resources are allowed to be deployed into"
  default     = ["centralindia", "southindia", "westeurope"]
}

variable "enable_delete_lock" {
  type        = bool
  description = "Apply a CanNotDelete lock on the resource group (recommended for prod only)"
  default     = false
}

variable "enable_budget" {
  type        = bool
  description = "Create a monthly cost budget with alerts"
  default     = true
}

variable "monthly_budget_amount" {
  type        = number
  description = "Monthly budget amount in the subscription's billing currency"
  default     = 100
}

variable "budget_start_date" {
  type        = string
  description = "RFC3339 first-of-month date the budget starts tracking from, e.g. 2026-08-01T00:00:00Z"
}

variable "budget_alert_emails" {
  type        = list(string)
  description = "Email addresses notified when the budget threshold is crossed"
  default     = []
}
