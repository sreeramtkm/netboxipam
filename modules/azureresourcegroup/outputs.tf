output "resourcegroupname" {
  value = try(azurerm_resource_group.resource_group.name, null)
}

