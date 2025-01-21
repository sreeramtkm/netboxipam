
resource "azurerm_subnet" "containerapp" {
  address_prefixes     = [element(var.subnetlist, 1)]
  name                 = replace(module.naming.subnet, "<id>", "containerapps")
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  delegation {
    name = "delegation"
    service_delegation {
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      name    = "Microsoft.App/environments"
    }
  }
}

resource "azurerm_subnet" "dbsubnet" {
  address_prefixes     = [element(var.subnetlist, 0)]
  name                 = replace(module.naming.subnet, "<id>", "dbsubnet")
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  service_endpoints    = ["Microsoft.Storage"]
  delegation {
    name = "Microsoft.DBforPostgreSQL.flexibleServers"
    service_delegation {
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      name    = "Microsoft.DBforPostgreSQL/flexibleServers"
    }
  }
}


resource "azurerm_virtual_network" "vnet" {
  address_space       = [var.vnetipaddressrange]
  location            = var.location
  name                = replace(module.naming.vnet, "<id>", var.unique_id)
  resource_group_name = azurerm_resource_group.rg.name
  tags                = {}
}
