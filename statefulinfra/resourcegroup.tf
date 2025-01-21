

# module "naming" {
#   source      = "../modules/naming"
#   environment = var.environment

# }

module "naming" {
  source      = "../modules/naming_convention/"
  environment = var.environment
  # also any inputs for the module (see below)
}

locals {
  dbname = replace(module.naming.postgresqldb, "<id>", var.unique_id)

}

resource "azurerm_resource_group" "rg" {
  name     = replace(replace(module.naming.resource_group, "<id>", var.unique_id), "<purpose>", var.purpose)
  location = "West Europe"
}

resource "azurerm_dns_zone" "rgstateless" {
  name                = var.dnszone
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_dns_zone" "proxydns" {
  name                = var.proxydnszone
  resource_group_name = azurerm_resource_group.rg.name
}