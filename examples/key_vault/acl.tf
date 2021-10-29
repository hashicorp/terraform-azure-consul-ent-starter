resource "random_uuid" "consul_server_default_token" {}

resource "azurerm_key_vault_secret" "consul_server_acl_tokens" {
  key_vault_id = azurerm_role_assignment.terraform_client.scope
  name         = "${var.resource_name_prefix}-consul-server-tokens"
  tags         = var.common_tags
  value        = "default = \"${random_uuid.consul_server_default_token.result}\""
}
