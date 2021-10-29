output "client_identity_client_id" {
  value = var.create_client_identity_id == true ? azurerm_user_assigned_identity.consul_client[0].client_id : null

  depends_on = [
    azurerm_role_assignment.consul_client_gossip_secret,
    azurerm_role_assignment.consul_client_license_secret,
    azurerm_role_assignment.consul_client_vmss_read,
  ]
}

output "client_identity_id" {
  value = var.create_client_identity_id == true ? azurerm_user_assigned_identity.consul_client[0].id : null

  depends_on = [
    azurerm_role_assignment.consul_client_gossip_secret,
    azurerm_role_assignment.consul_client_license_secret,
    azurerm_role_assignment.consul_client_vmss_read,
  ]
}

output "client_identity_principal_id" {
  value = var.create_client_identity_id == true ? azurerm_user_assigned_identity.consul_client[0].principal_id : null

  depends_on = [
    azurerm_role_assignment.consul_client_gossip_secret,
    azurerm_role_assignment.consul_client_license_secret,
    azurerm_role_assignment.consul_client_vmss_read,
  ]
}

output "server_identity_id" {
  value = var.user_supplied_identity_id != null ? var.user_supplied_identity_id : azurerm_user_assigned_identity.consul_server[0].id

  depends_on = [
    azurerm_role_assignment.consul_server_secrets,
    azurerm_role_assignment.consul_server_vmss_read,
  ]
}
