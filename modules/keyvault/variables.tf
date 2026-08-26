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

variable "tenant_id" {
  type        = string
  description = "The Tenant ID of the Active Directory"
}

variable "object_id" {
  type        = string
  description = "The Object ID of the service principal running Terraform"
}

variable "secrets" {
  type        = map(string)
  description = "Map of secret names to secret values"
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}

variable "purge_protection_enabled" {
  type        = bool
  description = "Prevent permanent deletion of the vault/secrets during the soft-delete window. Recommended true for prod; leave false for dev/staging so `terraform destroy` can actually purge the vault (purge protection cannot be turned off once enabled)."
  default     = false
}
