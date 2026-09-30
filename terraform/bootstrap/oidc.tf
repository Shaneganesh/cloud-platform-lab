resource "azurerm_user_assigned_identity" "github_actions" {
  name                = "id-github-actions-cloud-platform-lab"
  resource_group_name = azurerm_resource_group.core.name
  location            = azurerm_resource_group.core.location
}

resource "azurerm_federated_identity_credential" "github_actions_main" {
  name                = "github-actions-main-branch"
  resource_group_name = azurerm_resource_group.core.name
  parent_id           = azurerm_user_assigned_identity.github_actions.id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = "https://token.actions.githubusercontent.com"
  subject             = "repo:Shaneganesh/cloud-platform-lab:ref:refs/heads/main"
}

resource "azurerm_role_assignment" "github_actions_contributor" {
  scope                = azurerm_resource_group.core.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.github_actions.principal_id
}
