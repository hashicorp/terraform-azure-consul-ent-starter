locals {
  user_data = templatefile(
    var.user_supplied_userdata_path != null ? var.user_supplied_userdata_path : "${path.module}/templates/install_consul_server.sh.tpl",
    {
      acl_tokens_secret_id  = var.acl_tokens_secret_id
      consul_version        = var.consul_version
      instance_count        = var.instance_count
      gossip_secret_id      = var.gossip_secret_id
      license_secret_id     = var.license_secret_id
      name                  = var.resource_name_prefix
      resource_group_name   = var.resource_group.name
      server_scale_set_name = var.server_scale_set_name
      subscription_id       = var.subscription_id
      tenant_id             = var.tenant_id
      tls_secret_id         = var.tls_secret_id
    }
  )
}
