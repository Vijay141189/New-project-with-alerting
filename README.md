# Real estate platform infra — modular Terraform (Azure)

Same architecture as before, restructured into reusable modules with
`for_each` driving every repeated resource instead of copy-pasted blocks.

## Structure

```
providers.tf                # terraform + azurerm provider
variables.tf                 # root inputs, including backend_services map
main.tf                      # wires modules together, for_each over backend_services
outputs.tf                   # for_each map output -> one URL per backend service
terraform.tfvars.example     # sample values

modules/
  monitoring/     # Log Analytics + Application Insights + shared action group
  governance/     # tag/location Azure Policy, RG delete-lock, cost budget
  database/       # PostgreSQL Flexible Server (geo-redundant backup, optional HA + DR replica)
  cache/          # Redis
  storage/        # Storage account (GRS + versioning/soft-delete) + for_each over containers
  keyvault/       # Key Vault + for_each over secrets
  backup/         # Recovery Services Vault + operational blob backup
  app_service/    # ONE backend microservice (App Service + staging slot)
  frontend/       # Static Web App
  alerts/         # Diagnostic settings + metric alerts wired to every resource

envs/
  dev/, staging/, prod/   # backend.hcl (remote state) + <env>.tfvars per environment

.github/workflows/terraform.yml   # CI/CD: fmt/validate/plan on PR, apply on merge (dev/staging), manual approval gate for prod
```

## Governance, DR, backup & monitoring — what's where

| Concern | How it's implemented |
|---|---|
| **Governance** | `modules/governance`: Azure Policy assignments (require mandatory tags, restrict deployment regions), an optional `CanNotDelete` resource-group lock (prod only by default), and a monthly cost budget with 80%/100% email alerts. |
| **Backup** | Postgres: automated backups with configurable retention (`postgres_backup_retention_days`) + `geo_redundant_backup_enabled = true`. Storage: blob versioning, soft delete, change feed (`modules/storage`), plus a dedicated Data Protection vault doing operational (point-in-time restore) backup of the storage account (`modules/backup`). Key Vault already has soft-delete; `purge_protection_enabled` is exposed as a variable (on for prod). |
| **Disaster Recovery** | Storage account replication is configurable (`storage_replication_type`, GRS/RAGRS for cross-region durability). Postgres supports an optional cross-region **read replica** (`enable_dr_replica` + `dr_location`) you promote manually if the primary region goes down, plus optional zone-redundant HA (`enable_ha`) for same-region failover. Redis stays on Basic tier by default — note below on upgrading it. |
| **Monitoring** | `modules/monitoring` creates the Log Analytics workspace, Application Insights, and one shared action group. `modules/alerts` (declared last, since it depends on every other module's resource ID) wires diagnostic settings for every resource into the workspace and adds metric alerts: App Service 5xx count, Postgres CPU, Redis memory, storage availability. |
| **Pipeline** | `.github/workflows/terraform.yml` runs `fmt`/`validate`/`plan` on every PR for all three environments (plan posted as a PR comment) using Azure OIDC login (no stored client secret). Merges to `main` auto-apply dev/staging; prod only applies via manual `workflow_dispatch`, and the `prod` GitHub Environment should have required reviewers configured so a human approves before apply. |

## Usage

```bash
# local, one-off (dev environment)
cd envs/dev
export TF_VAR_postgres_admin_password="YourStrongPassword123!"
cd ../..
terraform init -backend-config=envs/dev/backend.hcl
terraform plan  -var-file=envs/dev/dev.tfvars
terraform apply -var-file=envs/dev/dev.tfvars
```

Before the first `terraform init`, create the storage account referenced in `envs/*/backend.hcl` (one-time, outside Terraform, since it holds the state Terraform itself needs):

```bash
az group create -n rg-terraform-state -l centralindia
az storage account create -n sttfstaterealestate -g rg-terraform-state -l centralindia --sku Standard_LRS
az storage container create -n tfstate --account-name sttfstaterealestate
```

### Running through the pipeline instead

Push a branch, open a PR against `main` — the workflow plans all three environments and comments the diff. Merging auto-applies dev + staging. To apply prod, run the workflow manually (`workflow_dispatch`) with `environment: prod`, `action: apply`; it'll wait for the required reviewers on the `prod` GitHub Environment.

Required repo secrets: `ARM_CLIENT_ID`, `ARM_TENANT_ID`, `ARM_SUBSCRIPTION_ID` (federated/OIDC app registration — no client secret needed) and `POSTGRES_ADMIN_PASSWORD`.

Check the URLs after apply:

```bash
terraform output backend_service_urls
# {
#   "booking" = "https://app-realestate-dev-booking.azurewebsites.net"
#   "listing" = "https://app-realestate-dev-listing.azurewebsites.net"
#   "payment" = "https://app-realestate-dev-payment.azurewebsites.net"
# }
```

## Adding a 4th microservice

Just edit `terraform.tfvars` (or `variables.tf` default):

```hcl
backend_services = {
  listing      = { description = "Property listing and search API" }
  booking      = { description = "Booking and availability API" }
  payment      = { description = "Payment processing API" }
  notification = { description = "SMS/email/WhatsApp notification service" }
}
```

Run `terraform plan` — you'll see exactly one new `module.backend_services["notification"]` plus its matching Key Vault access policy, nothing else touched.

## Notes for production

- Networking uses public endpoints for simplicity (small-scale brief). Add a VNet + private endpoints for Postgres/Redis/Storage before going to production.
- Backend runtime defaults to Node.js 20 (`modules/app_service/variables.tf` → `node_version`). Switch `application_stack` to `dotnet_version = "8.0"` if using .NET.
- Azure AD B2C isn't in Terraform yet (not fully supported by the `azurerm` provider) — set it up once via the portal and feed its IDs in as app settings.
- Redis stays on the **Basic** SKU by default (no SLA, no geo-replication). If Redis needs to survive a regional outage, move to **Premium** and add `redis_configuration { ... }` + a linked geo-replicated cache — Basic/Standard don't support it.
- `enable_delete_lock = true` (set in `envs/prod/prod.tfvars`) will block `terraform destroy` while active. Flip it to `false` and re-apply before tearing prod down on purpose.
- `keyvault_purge_protection_enabled = true` in prod is permanent once applied — the vault can be soft-deleted but never purged before its retention window expires, even by Terraform.
