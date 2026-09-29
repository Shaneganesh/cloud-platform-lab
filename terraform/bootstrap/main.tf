# Resource group already exists (created via az cli) — this block will be
# brought under Terraform management via `terraform import`, not created fresh.
resource "azurerm_resource_group" "core" {
  name     = "rg-cloud-platform-lab"
  location = "southafricanorth"
}

resource "azurerm_storage_account" "tfstate" {
  name                = "stcloudplatformlab"
  resource_group_name = azurerm_resource_group.core.name
  location            = azurerm_resource_group.core.location

  account_tier             = "Standard"
  account_replication_type = "LRS"

  min_tls_version                 = "TLS1_2"
  public_network_access_enabled   = true
  allow_nested_items_to_be_public = false
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.tfstate.id
  container_access_type = "private"
}
