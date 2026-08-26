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

variable "storage_account_id" {
  type        = string
  description = "Resource ID of the storage account to protect with operational (point-in-time restore) backup"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}
