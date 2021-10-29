provider "azurerm" {
  features {}
}

resource "azurerm_virtual_network" "consul" {
  location            = var.resource_group.location
  name                = "${var.resource_name_prefix}-consul"
  resource_group_name = var.resource_group.name
  tags                = var.common_tags

  address_space = [
    var.address_space,
  ]
}

resource "azurerm_subnet" "consul" {
  name                 = "${var.resource_name_prefix}-consul"
  resource_group_name  = var.resource_group.name
  virtual_network_name = azurerm_virtual_network.consul.name

  address_prefixes = [
    var.consul_address_prefix,
  ]

  service_endpoints = [
    "Microsoft.KeyVault",
  ]
}

resource "azurerm_application_security_group" "consul_clients" {
  location            = var.resource_group.location
  name                = "${var.resource_name_prefix}-consul-clients"
  resource_group_name = var.resource_group.name
  tags                = var.common_tags
}

resource "azurerm_application_security_group" "consul_servers" {
  location            = var.resource_group.location
  name                = "${var.resource_name_prefix}-consul-servers"
  resource_group_name = var.resource_group.name
  tags                = var.common_tags
}

resource "azurerm_network_security_group" "consul" {
  location            = var.resource_group.location
  name                = "${var.resource_name_prefix}-consul"
  resource_group_name = var.resource_group.name
  tags                = var.common_tags
}

resource "azurerm_network_security_rule" "consul_internet_access" {
  access                      = "Allow"
  destination_address_prefix  = "*"
  destination_port_range      = "*"
  direction                   = "Outbound"
  name                        = "${var.resource_name_prefix}-consul-access-to-internet"
  network_security_group_name = azurerm_network_security_group.consul.name
  priority                    = 100
  protocol                    = "Tcp"
  resource_group_name         = var.resource_group.name
  source_address_prefix       = "*"
  source_port_range           = "*"
}

resource "azurerm_network_security_rule" "consul_server_rpc" {
  access                      = "Allow"
  description                 = "Used by servers to handle incoming requests from other agents"
  destination_port_range      = "8300"
  direction                   = "Inbound"
  name                        = "${var.resource_name_prefix}-consul-server-rpc"
  network_security_group_name = azurerm_network_security_group.consul.name
  priority                    = 110
  protocol                    = "Tcp"
  resource_group_name         = var.resource_group.name
  source_port_range           = "*"

  destination_application_security_group_ids = [
    azurerm_application_security_group.consul_servers.id,
  ]

  source_application_security_group_ids = [
    azurerm_application_security_group.consul_servers.id,
  ]
}

resource "azurerm_network_security_rule" "consul_server_rpc_from_clients" {
  access                      = "Allow"
  description                 = "Used by servers to handle incoming requests from other agents"
  destination_port_range      = "8300"
  direction                   = "Inbound"
  name                        = "${var.resource_name_prefix}-consul-server-rpc-from-clients"
  network_security_group_name = azurerm_network_security_group.consul.name
  priority                    = 111
  protocol                    = "Tcp"
  resource_group_name         = var.resource_group.name
  source_port_range           = "*"

  destination_application_security_group_ids = [
    azurerm_application_security_group.consul_servers.id,
  ]

  source_application_security_group_ids = [
    azurerm_application_security_group.consul_clients.id,
  ]
}

resource "azurerm_network_security_rule" "consul_lan_serf" {
  for_each = {
    server-to-server-tcp = {
      priority    = 120
      protocol    = "Tcp"
      destination = azurerm_application_security_group.consul_servers.id
      source      = azurerm_application_security_group.consul_servers.id
    }
    server-to-server-udp = {
      priority    = 121
      protocol    = "Udp"
      destination = azurerm_application_security_group.consul_servers.id
      source      = azurerm_application_security_group.consul_servers.id
    }
    client-to-server-tcp = {
      priority    = 122
      protocol    = "Tcp"
      destination = azurerm_application_security_group.consul_servers.id
      source      = azurerm_application_security_group.consul_clients.id
    }
    client-to-server-udp = {
      priority    = 123
      protocol    = "Udp"
      destination = azurerm_application_security_group.consul_servers.id
      source      = azurerm_application_security_group.consul_clients.id
    }
    server-to-client-tcp = {
      priority    = 124
      protocol    = "Tcp"
      destination = azurerm_application_security_group.consul_clients.id
      source      = azurerm_application_security_group.consul_servers.id
    }
    server-to-client-udp = {
      priority    = 125
      protocol    = "Udp"
      destination = azurerm_application_security_group.consul_clients.id
      source      = azurerm_application_security_group.consul_servers.id
    }
    client-to-client-tcp = {
      priority    = 126
      protocol    = "Tcp"
      destination = azurerm_application_security_group.consul_clients.id
      source      = azurerm_application_security_group.consul_clients.id
    }
    client-to-client-udp = {
      priority    = 127
      protocol    = "Udp"
      destination = azurerm_application_security_group.consul_clients.id
      source      = azurerm_application_security_group.consul_clients.id
    }
  }

  access                      = "Allow"
  description                 = "Used to handle gossip in the LAN"
  destination_port_range      = "8301"
  direction                   = "Inbound"
  name                        = "${var.resource_name_prefix}-consul-lan-serf-${each.key}"
  network_security_group_name = azurerm_network_security_group.consul.name
  priority                    = each.value.priority
  protocol                    = each.value.protocol
  resource_group_name         = var.resource_group.name
  source_port_range           = "*"

  destination_application_security_group_ids = [
    each.value.destination,
  ]

  source_application_security_group_ids = [
    each.value.source,
  ]
}

resource "azurerm_network_security_rule" "consul_grpc" {
  access                      = "Allow"
  description                 = "Exposes the xDS API to Envoy proxies"
  destination_port_range      = "8502"
  direction                   = "Inbound"
  name                        = "${var.resource_name_prefix}-consul-grpc"
  network_security_group_name = azurerm_network_security_group.consul.name
  priority                    = 130
  protocol                    = "Tcp"
  resource_group_name         = var.resource_group.name
  source_port_range           = "*"

  destination_application_security_group_ids = [
    azurerm_application_security_group.consul_servers.id,
  ]

  source_application_security_group_ids = [
    azurerm_application_security_group.consul_clients.id,
  ]
}

resource "azurerm_network_security_rule" "consul_server_other_inbound" {
  access                      = "Deny"
  description                 = "Deny any non-matched traffic"
  destination_port_range      = "8300-8502"
  direction                   = "Inbound"
  name                        = "${var.resource_name_prefix}-consul-server-other-inbound"
  network_security_group_name = azurerm_network_security_group.consul.name
  priority                    = 200
  protocol                    = "*"
  resource_group_name         = var.resource_group.name
  source_address_prefix       = "*"
  source_port_range           = "*"

  destination_application_security_group_ids = [
    azurerm_application_security_group.consul_servers.id,
  ]
}

resource "azurerm_subnet_network_security_group_association" "consul" {
  network_security_group_id = azurerm_network_security_group.consul.id
  subnet_id                 = azurerm_subnet.consul.id

  depends_on = [
    azurerm_network_security_rule.consul_internet_access,
    azurerm_network_security_rule.consul_server_rpc,
    azurerm_network_security_rule.consul_server_rpc_from_clients,
    azurerm_network_security_rule.consul_lan_serf,
    azurerm_network_security_rule.consul_grpc,
    azurerm_network_security_rule.consul_server_other_inbound,
  ]
}

resource "azurerm_nat_gateway" "consul" {
  location            = var.resource_group.location
  name                = "${var.resource_name_prefix}-consul"
  resource_group_name = var.resource_group.name
  sku_name            = "Standard"
  tags                = var.common_tags
}

resource "azurerm_public_ip" "consul_nat" {
  allocation_method   = "Static"
  location            = var.resource_group.location
  name                = "${var.resource_name_prefix}-consul-nat"
  resource_group_name = var.resource_group.name
  sku                 = "Standard"
  tags                = var.common_tags
}

resource "azurerm_nat_gateway_public_ip_association" "consul" {
  nat_gateway_id       = azurerm_nat_gateway.consul.id
  public_ip_address_id = azurerm_public_ip.consul_nat.id
}

resource "azurerm_subnet_nat_gateway_association" "consul" {
  nat_gateway_id = azurerm_nat_gateway_public_ip_association.consul.nat_gateway_id
  subnet_id      = azurerm_subnet.consul.id
}

# Azure Bastion Service is not required for Consul operation, but it
# provides an secure and easy to use way access to the Consul VMs
resource "azurerm_public_ip" "abs" {
  count = var.abs_address_prefix == null ? 0 : 1

  allocation_method   = "Static"
  location            = var.resource_group.location
  name                = "${var.resource_name_prefix}-consul-abs"
  resource_group_name = var.resource_group.name
  sku                 = "Standard"
  tags                = var.common_tags
}

resource "azurerm_subnet" "consul_abs" {
  count = var.abs_address_prefix == null ? 0 : 1

  address_prefixes     = [var.abs_address_prefix] # at least /27 or larger
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.resource_group.name
  virtual_network_name = azurerm_virtual_network.consul.name
}

resource "azurerm_bastion_host" "main" {
  count = var.abs_address_prefix == null ? 0 : 1

  location            = var.resource_group.location
  name                = "${var.resource_name_prefix}-consul-abs"
  resource_group_name = var.resource_group.name
  tags                = var.common_tags

  ip_configuration {
    name                 = "${var.resource_name_prefix}-consul-abs"
    public_ip_address_id = azurerm_public_ip.abs[0].id
    subnet_id            = azurerm_subnet.consul_abs[0].id
  }
}
