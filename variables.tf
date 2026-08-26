variable "project_name" {
  type    = string
  default = "realestate"
}

variable "environment" {
  type    = string
  default = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "location" {
  type    = string
  default = "centralindia"
}

variable "dr_location" {
  description = "Paired Azure region used for the Postgres DR read replica and as an allowed governance location"
  type        = string
  default     = "southindia"
}

variable "app_service_sku" {
  description = "Shared App Service Plan SKU. B1 is fine for small scale (500-1000 users)."
  type        = string
  default     = "B1"
}

# One entry per backend microservice. Add a fourth service (e.g. "notification")
# by adding one more map entry here - the for_each in main.tf handles the rest.
variable "backend_services" {
  type = map(object({
    description = string
  }))
  default = {
    listing = {
      description = "Property listing and search API"
    }
    booking = {
      description = "Booking and availability API"
    }
    payment = {
      description = "Payment processing API"
    }
  }
}

variable "postgres_admin_username" {
  type    = string
  default = "pgadmin"
}

variable "postgres_admin_password" {
  description = "Set via TF_VAR_postgres_admin_password env var - never commit this to git."
  type        = string
  sensitive   = true
}

variable "storage_containers" {
  type = map(string)
  default = {
    "property-media" = "private"
    "documents"       = "private"
  }
}

variable "tags" {
  type = map(string)
  default = {
    project   = "realestate-digital-transformation"
    managedBy = "terraform"
  }
}

# ---------------------------------------------------------------------------
# Governance / DR / backup / monitoring knobs. Sensible per-environment
# defaults are supplied via envs/<env>.tfvars in the CI pipeline; the
# defaults below are safe for local/dev use.
# ---------------------------------------------------------------------------

variable "alert_emails" {
  description = "Email addresses that receive monitoring alerts and budget notifications"
  type        = list(string)
  default     = []
}

variable "monthly_budget_amount" {
  description = "Monthly cost budget for the resource group (subscription currency)"
  type        = number
  default     = 100
}

variable "enable_delete_lock" {
  description = "Apply a CanNotDelete lock on the resource group. Turn on for prod only - it will block `terraform destroy` while enabled."
  type        = bool
  default     = false
}

variable "enable_ha" {
  description = "Enable zone-redundant HA on PostgreSQL (adds a synchronous standby). Recommended for staging/prod."
  type        = bool
  default     = false
}

variable "enable_dr_replica" {
  description = "Create a cross-region PostgreSQL read replica in var.dr_location for disaster recovery"
  type        = bool
  default     = false
}

variable "postgres_backup_retention_days" {
  description = "Days automated PostgreSQL backups are retained (7-35)"
  type        = number
  default     = 14
}

variable "storage_replication_type" {
  description = "Storage account replication. GRS/RA-GRS enable cross-region DR."
  type        = string
  default     = "GRS"
}

variable "keyvault_purge_protection_enabled" {
  description = "Enable Key Vault purge protection. Recommended true for prod only (cannot be disabled once on, complicates `terraform destroy`)."
  type        = bool
  default     = false
}
