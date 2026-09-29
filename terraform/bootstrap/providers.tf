terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  # Local state for this bootstrap config only.
  # Once the storage account below exists, all OTHER Terraform configs
  # (starting with Step 4's main infra) use a remote "azurerm" backend
  # pointed at it. This bootstrap config stays on local state permanently,
  # since it creates the very thing a remote backend would depend on.
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}
