provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "random_id" "key_vault_suffix" {
  byte_length = floor((24 - (length(var.resource_name_prefix) + 8)) / 2)
}

resource "azurerm_key_vault" "consul" {
  enable_rbac_authorization = true
  location                  = var.resource_group.location
  name                      = "${var.resource_name_prefix}-consul-${random_id.key_vault_suffix.hex}"
  resource_group_name       = var.resource_group.name
  sku_name                  = "standard"
  tags                      = var.common_tags
  tenant_id                 = data.azurerm_client_config.current.tenant_id
}

resource "azurerm_role_assignment" "terraform_client" {
  principal_id         = data.azurerm_client_config.current.object_id
  role_definition_name = "Key Vault Administrator"
  scope                = azurerm_key_vault.consul.id
}

resource "azurerm_key_vault_secret" "consul" {
  key_vault_id = azurerm_role_assignment.terraform_client.scope
  name         = "${var.resource_name_prefix}-consul-server-tls"
  tags         = var.common_tags
  value        = local.secret
}
