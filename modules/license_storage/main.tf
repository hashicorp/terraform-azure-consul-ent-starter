resource "azurerm_key_vault_secret" "consul_license" {
  key_vault_id = var.key_vault_id
  name         = "${var.resource_name_prefix}-consul-license"
  tags         = var.common_tags
  value        = filebase64(var.consul_license_filepath)
}
