resource "random_id" "gossip_encryption" {
  byte_length = 32
}

resource "azurerm_key_vault_secret" "gossip_encryption" {
  key_vault_id = azurerm_role_assignment.terraform_client.scope
  name         = "${var.resource_name_prefix}-consul-gossip"
  tags         = var.common_tags
  value        = random_id.gossip_encryption.b64_std
}
