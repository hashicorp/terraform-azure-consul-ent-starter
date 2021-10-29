output "client_application_security_group_id" {
  value = azurerm_application_security_group.consul_clients.id
}

output "consul_subnet_id" {
  value = azurerm_subnet_network_security_group_association.consul.id

  depends_on = [
    azurerm_subnet_nat_gateway_association.consul,
  ]
}

output "network_security_group_name" {
  value = azurerm_network_security_group.consul.name
}

output "server_application_security_group_id" {
  value = azurerm_application_security_group.consul_servers.id
}

output "virtual_network_name" {
  value = azurerm_virtual_network.consul.name

  depends_on = [
    azurerm_subnet_network_security_group_association.consul,
  ]
}
