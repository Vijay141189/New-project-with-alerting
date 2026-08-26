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

variable "containers" {
  type        = map(string)
  description = "Map of container names to access types"
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}

variable "replication_type" {
  type        = string
  description = "Storage replication type. GRS/RA-GRS give cross-region DR; LRS is single-region only."
  default     = "GRS"
}

variable "blob_soft_delete_days" {
  type        = number
  description = "Days deleted blobs/containers are recoverable before permanent deletion"
  default     = 14
}
