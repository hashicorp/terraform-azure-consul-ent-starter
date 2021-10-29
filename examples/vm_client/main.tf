data "azurerm_client_config" "current" {}

resource "random_uuid" "consul_client_default_token" {}

resource "azurerm_key_vault_secret" "consul_example_app_acl_tokens" {
  key_vault_id = var.key_vault_id
  name         = "${var.resource_name_prefix}-consul-example-app-tokens"
  tags         = var.common_tags
  value        = "default = \"${random_uuid.consul_client_default_token.result}\""
}

resource "azurerm_user_assigned_identity" "example_app" {
  location            = var.resource_group.location
  name                = "${var.resource_name_prefix}-consul-example-app"
  resource_group_name = var.resource_group.name
  tags                = var.common_tags
}

resource "azurerm_role_assignment" "app_acl_secret" {
  principal_id         = azurerm_user_assigned_identity.example_app.principal_id
  role_definition_name = "Key Vault Secrets User"
  scope                = "${var.key_vault_id}/secrets/${split("/", azurerm_key_vault_secret.consul_example_app_acl_tokens.id)[4]}" # retrieving secret name from id, e.g. "foo" from "https://KEYVAULTNAME.vault.azure.net/secrets/foo/d6aa9d46a3e24df1b5e871396072b6ed"
}

locals {
  user_data = base64encode(templatefile(
    var.user_supplied_userdata_path != null ? var.user_supplied_userdata_path : "${path.module}/templates/install_consul_client.sh.tpl",
    {
      app_identity_client_id = azurerm_user_assigned_identity.example_app.client_id
      acl_tokens_secret_id   = azurerm_key_vault_secret.consul_example_app_acl_tokens.id
      ca_cert                = var.ca_cert
      client_id              = var.identity_client_id
      consul_version         = var.consul_version
      gossip_secret_id       = var.gossip_secret_id
      instance_count         = var.instance_count
      license_secret_id      = var.license_secret_id
      name                   = var.resource_name_prefix
      resource_group_name    = var.resource_group.name
      server_scale_set_name  = var.server_vm_scale_set_name
      subscription_id        = data.azurerm_client_config.current.subscription_id
      tenant_id              = data.azurerm_client_config.current.tenant_id
    }
  ))
  vm_scale_set_name = var.vm_scale_set_name == null ? "${var.resource_name_prefix}-consul-client" : var.vm_scale_set_name
}

resource "azurerm_linux_virtual_machine_scale_set" "consul_client" {
  admin_username      = var.ssh_username
  instances           = var.instance_count
  location            = var.resource_group.location
  name                = local.vm_scale_set_name
  overprovision       = false
  resource_group_name = var.resource_group.name
  sku                 = var.instance_type
  source_image_id     = var.user_supplied_source_image_id
  upgrade_mode        = "Rolling"
  zone_balance        = var.zones == null ? false : true
  zones               = var.zones

  # user_data = var.user_data
  # Actual "userData" support is pending in Terraform
  # https://github.com/terraform-providers/terraform-provider-azurerm/issues/11846
  # Fine to just use with the legacy custom_data API instead
  custom_data = local.user_data

  additional_capabilities {
    ultra_ssd_enabled = var.ultra_ssd_enabled
  }

  dynamic "admin_ssh_key" {
    for_each = var.ssh_public_key == "" ? [] : [1]
    content {
      username   = var.ssh_username
      public_key = var.ssh_public_key
    }
  }

  dynamic "extension" {
    for_each = var.health_check_path != null ? [1] : []

    content {
      auto_upgrade_minor_version = true
      name                       = "${var.resource_name_prefix}-consul-example-app-health"
      publisher                  = "Microsoft.ManagedServices"
      type                       = "ApplicationHealthLinux"
      type_handler_version       = "1.0"

      settings = jsonencode({
        "port" : 8500,
        "protocol" : "http",
        "requestPath" : var.health_check_path
      })
    }
  }

  network_interface {
    name    = "${var.resource_name_prefix}-consul-example-app"
    primary = true

    ip_configuration {
      application_security_group_ids = var.application_security_group_ids
      name                           = "${var.resource_name_prefix}-consul-example-app"
      primary                        = true
      subnet_id                      = var.subnet_id
    }
  }

  identity {
    type = "UserAssigned"

    identity_ids = [
      azurerm_user_assigned_identity.example_app.id,
      var.identity_id,
    ]
  }

  os_disk {
    caching              = "ReadWrite"
    disk_size_gb         = 1024
    storage_account_type = var.os_disk_type
  }

  rolling_upgrade_policy {
    max_batch_instance_percent              = 20
    max_unhealthy_instance_percent          = 20
    max_unhealthy_upgraded_instance_percent = 20
    pause_time_between_batches              = "PT1M"
  }

  dynamic "source_image_reference" {
    for_each = var.user_supplied_source_image_id == null ? [1] : [0]
    content {
      offer     = "0001-com-ubuntu-server-focal"
      publisher = "Canonical"
      sku       = "20_04-lts-gen2"
      version   = "latest"
    }
  }

  tags = merge(
    {
      "${var.resource_name_prefix}-consul" = "example-app"
    },
    var.common_tags
  )

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    azurerm_role_assignment.app_acl_secret,
  ]
}
