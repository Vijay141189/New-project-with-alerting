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

variable "admin_username" {
  type        = string
  description = "Database administrator username"
}

variable "admin_password" {
  type        = string
  description = "Database administrator password"
  sensitive   = true
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}

variable "backup_retention_days" {
  type        = number
  description = "Number of days automated backups are retained (7-35)"
  default     = 14
}

variable "geo_redundant_backup_enabled" {
  type        = bool
  description = "Store automated backups in the paired region for geo-restore DR"
  default     = true
}

variable "high_availability_enabled" {
  type        = bool
  description = "Enable zone-redundant HA (adds a synchronously-replicated standby). Increases cost - typically on for staging/prod only."
  default     = false
}

variable "standby_zone" {
  type        = string
  description = "Availability zone for the HA standby, must differ from the primary zone"
  default     = "2"
}

variable "enable_dr_replica" {
  type        = bool
  description = "Create a cross-region read replica for disaster recovery"
  default     = false
}

variable "dr_location" {
  type        = string
  description = "Azure region for the DR read replica (must differ from the primary region)"
  default     = null
}
