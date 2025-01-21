resource "azurerm_dns_zone" "dnszone" {
  name                = var.dnszonename
  resource_group_name = var.resourcegroupname
}
