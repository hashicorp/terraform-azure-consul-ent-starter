provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "consul" {
  location = var.location
  name     = "${var.resource_name_prefix}-consul"
  tags     = var.common_tags
}
