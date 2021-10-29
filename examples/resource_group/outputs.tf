output "resource_group" {
  value = {
    id       = azurerm_resource_group.consul.id
    location = azurerm_resource_group.consul.location
    name     = azurerm_resource_group.consul.name
  }
}
