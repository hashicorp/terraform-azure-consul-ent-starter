resource "azurerm_linux_virtual_machine_scale_set" "consul_cluster" {
  admin_username      = var.ssh_username
  instances           = var.instance_count
  location            = var.resource_group.location
  name                = var.scale_set_name
  overprovision       = false
  resource_group_name = var.resource_group.name
  sku                 = var.instance_type
  source_image_id     = var.user_supplied_source_image_id
  upgrade_mode        = var.upgrade_mode
  zone_balance        = var.zones == null ? false : true
  zones               = var.zones

  # user_data = var.user_data
  # Actual "userData" support is pending in Terraform
  # https://github.com/terraform-providers/terraform-provider-azurerm/issues/11846
  # Fine to just use with the legacy custom_data API instead
  custom_data = var.user_data

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
      name                       = "${var.resource_name_prefix}-consul-health"
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
    dns_servers = []
    name        = "${var.resource_name_prefix}-consul"
    primary     = true

    ip_configuration {
      application_security_group_ids = var.application_security_group_ids
      name                           = "${var.resource_name_prefix}-consul"
      primary                        = true
      subnet_id                      = var.subnet_id
    }
  }

  identity {
    identity_ids = var.identity_ids
    type         = "UserAssigned"
  }

  os_disk {
    caching              = "ReadWrite"
    disk_size_gb         = 1024
    storage_account_type = var.os_disk_type
  }

  dynamic "rolling_upgrade_policy" {
    for_each = var.rolling_upgrade_policy != "Manual" && var.rolling_upgrade_policy != null ? [1] : []

    content {
      max_batch_instance_percent              = var.rolling_upgrade_policy.max_batch_instance_percent
      max_unhealthy_instance_percent          = var.rolling_upgrade_policy.max_unhealthy_instance_percent
      max_unhealthy_upgraded_instance_percent = var.rolling_upgrade_policy.max_unhealthy_upgraded_instance_percent
      pause_time_between_batches              = var.rolling_upgrade_policy.pause_time_between_batches
    }
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
      "${var.resource_name_prefix}-consul" = "server"
    },
    var.common_tags
  )

  lifecycle {
    create_before_destroy = true
  }
}
