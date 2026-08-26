variable "project_prefix" {
  type        = string
  description = "Project name and environment prefix"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}

variable "alert_emails" {
  type        = list(string)
  description = "Email addresses that receive alert notifications"
  default     = []
}
