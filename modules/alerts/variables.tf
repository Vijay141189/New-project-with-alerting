variable "project_prefix" {
  type        = string
  description = "Project name and environment prefix"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "ID of the Log Analytics workspace to send diagnostics to"
}

variable "action_group_id" {
  type        = string
  description = "ID of the Monitor action group notified by alerts"
}

# key => resource ID. Any resource type is fine here (diagnostic settings
# support most Azure resources uniformly).
variable "diagnostic_targets" {
  type        = map(string)
  description = "Map of friendly name -> resource ID to forward logs/metrics for"
  default     = {}
}

variable "app_service_ids" {
  type        = map(string)
  description = "Map of backend service name -> App Service resource ID"
  default     = {}
}

variable "postgres_id" {
  type        = string
  description = "Resource ID of the PostgreSQL Flexible Server"
}

variable "redis_id" {
  type        = string
  description = "Resource ID of the Redis cache"
}

variable "storage_id" {
  type        = string
  description = "Resource ID of the storage account"
}

variable "error_count_threshold" {
  type        = number
  description = "Number of 5xx responses in the window before alerting"
  default     = 10
}

variable "cpu_threshold_percent" {
  type        = number
  default     = 80
}

variable "memory_threshold_percent" {
  type        = number
  default     = 80
}

variable "availability_threshold_percent" {
  type        = number
  default     = 99
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}
