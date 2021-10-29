resource "azurerm_role_definition" "consul_vmss_read" {
  count = var.create_client_identity_id == false && var.user_supplied_identity_id != null ? 0 : 1

  name  = "${var.resource_name_prefix}-consul"
  scope = var.resource_group.id

  assignable_scopes = [
    var.resource_group.id,
  ]

  permissions {
    actions = [
      "Microsoft.Compute/virtualMachineScaleSets/*/read",
    ]
  }
}

resource "azurerm_user_assigned_identity" "consul_server" {
  count = var.user_supplied_identity_id != null ? 0 : 1

  location            = var.resource_group.location
  name                = "${var.resource_name_prefix}-consul-server"
  resource_group_name = var.resource_group.name
  tags                = var.common_tags
}

resource "azurerm_role_assignment" "consul_server_vmss_read" {
  count = var.user_supplied_identity_id != null ? 0 : 1

  principal_id       = azurerm_user_assigned_identity.consul_server[0].principal_id
  role_definition_id = azurerm_role_definition.consul_vmss_read[0].role_definition_resource_id
  scope              = var.resource_group.id
}

resource "azurerm_role_assignment" "consul_server_secrets" {
  count = var.user_supplied_identity_id != null ? 0 : 1

  principal_id         = azurerm_user_assigned_identity.consul_server[0].principal_id
  role_definition_name = "Key Vault Secrets User"
  scope                = var.key_vault_id
}

resource "azurerm_user_assigned_identity" "consul_client" {
  count = var.create_client_identity_id == true ? 1 : 0

  location            = var.resource_group.location
  name                = "${var.resource_name_prefix}-consul-client"
  resource_group_name = var.resource_group.name
  tags                = var.common_tags
}

resource "azurerm_role_assignment" "consul_client_vmss_read" {
  count = var.create_client_identity_id == true ? 1 : 0

  principal_id       = azurerm_user_assigned_identity.consul_client[0].principal_id
  role_definition_id = azurerm_role_definition.consul_vmss_read[0].role_definition_resource_id
  scope              = var.resource_group.id
}

resource "azurerm_role_assignment" "consul_client_gossip_secret" {
  count = var.create_client_identity_id == true ? 1 : 0

  principal_id         = azurerm_user_assigned_identity.consul_client[0].principal_id
  role_definition_name = "Key Vault Secrets User"
  scope                = "${var.key_vault_id}/secrets/${split("/", var.gossip_secret_id)[4]}" # retrieving secret name from id, e.g. "foo" from "https://KEYVAULTNAME.vault.azure.net/secrets/foo/d6aa9d46a3e24df1b5e871396072b6ed"
}

resource "azurerm_role_assignment" "consul_client_license_secret" {
  count = var.create_client_identity_id == true ? 1 : 0

  principal_id         = azurerm_user_assigned_identity.consul_client[0].principal_id
  role_definition_name = "Key Vault Secrets User"
  scope                = "${var.key_vault_id}/secrets/${split("/", var.license_secret_id)[4]}" # retrieving secret name from id, e.g. "foo" from "https://KEYVAULTNAME.vault.azure.net/secrets/foo/d6aa9d46a3e24df1b5e871396072b6ed"
}
