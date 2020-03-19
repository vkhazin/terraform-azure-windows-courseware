# Create the network VNET
resource "azurerm_virtual_network" "network-vnet" {
  depends_on  = [
    azurerm_resource_group.rg-environment
  ]

  name                = "vnet-${lower(replace(var.app_name," ","-"))}-${var.environment}"
  address_space       = [var.network_vnet_cidr]
  resource_group_name = azurerm_resource_group.rg-environment.name
  location            = azurerm_resource_group.rg-environment.location
  tags = {
    application = var.app_name
    environment = var.environment
  }
}

resource "azurerm_subnet" "network-public-subnet" {
  depends_on  = [
    azurerm_virtual_network.network-vnet
  ]

  name                 = "public-snet-${lower(replace(var.app_name," ","-"))}-${var.environment}"
  address_prefix       = var.public_subnet_cidr
  virtual_network_name = azurerm_virtual_network.network-vnet.name
  resource_group_name  = azurerm_resource_group.rg-environment.name
}

resource "azurerm_subnet" "network-private-subnet" {
  depends_on=[azurerm_virtual_network.network-vnet]

  name                 = "private-snet-${lower(replace(var.app_name," ","-"))}-${var.environment}"
  address_prefix       = var.private_subnet_cidr
  virtual_network_name = azurerm_virtual_network.network-vnet.name
  resource_group_name  = azurerm_resource_group.rg-environment.name
}

resource "azurerm_route_table" "private-subnet-route" {
  name                          = "private-rt-${lower(replace(var.app_name," ","-"))}-${var.environment}"
  resource_group_name           = azurerm_resource_group.rg-environment.name
  location                      = azurerm_resource_group.rg-environment.location
  disable_bgp_route_propagation = false

  route {
    name                   = "private-subnet-default-route"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "Internet"
  }

  tags = {
    application = var.app_name
    environment = var.environment
  }
}

resource "azurerm_subnet_route_table_association" "private-subnet-route-association" {
  subnet_id      = azurerm_subnet.network-private-subnet.id
  route_table_id = azurerm_route_table.private-subnet-route.id
}