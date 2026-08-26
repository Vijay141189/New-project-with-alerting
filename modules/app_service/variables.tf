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

variable "service_plan_id" {
  type        = string
  description = "ID of the App Service Plan"
}

variable "node_version" {
  type        = string
  description = "Node.js version for the application stack"
  default     = "20-lts"
}

variable "app_settings" {
  type        = map(string)
  description = "Application settings for the App Service"
  default     = {}
}

variable "create_staging_slot" {
  type        = bool
  description = "Flag to determine if staging slot should be created"
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}
