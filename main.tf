data "azurerm_client_config" "current" {}

locals {
  server_scale_set_name = "${var.resource_name_prefix}-consul-server"
}

module "license_storage" {
  source = "./modules/license_storage"

  common_tags             = var.common_tags
  consul_license_filepath = var.consul_license_filepath
  key_vault_id            = var.key_vault_id
  resource_name_prefix    = var.resource_name_prefix
}

module "iam" {
  source = "./modules/iam"

  common_tags               = var.common_tags
  create_client_identity_id = var.create_client_identity_id
  gossip_secret_id          = var.gossip_secret_id
  key_vault_id              = var.key_vault_id
  license_secret_id         = module.license_storage.license_secret_id
  resource_group            = var.resource_group
  resource_name_prefix      = var.resource_name_prefix
  tenant_id                 = data.azurerm_client_config.current.tenant_id
  user_supplied_identity_id = var.user_supplied_identity_id
}

module "user_data" {
  source = "./modules/user_data"

  acl_tokens_secret_id        = var.acl_tokens_secret_id
  ca_cert                     = var.ca_cert
  consul_version              = var.consul_version
  instance_count              = var.instance_count
  gossip_secret_id            = var.gossip_secret_id
  license_secret_id           = module.license_storage.license_secret_id
  resource_group              = var.resource_group
  resource_name_prefix        = var.resource_name_prefix
  server_scale_set_name       = local.server_scale_set_name
  subscription_id             = data.azurerm_client_config.current.subscription_id
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  tls_secret_id               = var.tls_secret_id
  user_supplied_userdata_path = var.user_supplied_userdata_path
}

module "vm" {
  source = "./modules/vm"

  application_security_group_ids = var.application_security_group_ids
  common_tags                    = var.common_tags
  health_check_path              = var.health_check_path
  instance_count                 = var.instance_count
  instance_type                  = var.instance_type
  resource_group                 = var.resource_group
  resource_name_prefix           = var.resource_name_prefix
  rolling_upgrade_policy         = var.scale_set_rolling_upgrade_policy
  scale_set_name                 = local.server_scale_set_name
  ssh_public_key                 = var.ssh_public_key
  subnet_id                      = var.subnet_id
  ultra_ssd_enabled              = var.ultra_ssd_enabled
  upgrade_mode                   = var.scale_set_upgrade_mode
  user_data                      = module.user_data.userdata_base64_encoded
  user_supplied_source_image_id  = var.user_supplied_source_image_id
  zones                          = var.zones

  identity_ids = [
    module.iam.server_identity_id,
  ]
}
