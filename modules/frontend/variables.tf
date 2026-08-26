variable "project_prefix" {
  type        = string
  description = "Project name and environment prefix"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region for Static Web App (must be a supported region)"
  default     = "westeurope"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}
