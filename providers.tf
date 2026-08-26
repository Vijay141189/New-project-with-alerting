terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
  }

  # Backend config is supplied at `terraform init` time via
  # `-backend-config=envs/<env>/backend.hcl` (see envs/ and the CI pipeline
  # in .github/workflows/terraform.yml). Keeping this block empty lets the
  # same code deploy dev/staging/prod into separate state files/containers.
  backend "azurerm" {}
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

data "azurerm_client_config" "current" {}
