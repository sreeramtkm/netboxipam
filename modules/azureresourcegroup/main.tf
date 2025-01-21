module "naming" {
  source = "git::https://ngi001@dev.azure.com/ngi001/digital-services-config/_git/terraformmodules?ref=naming_convention/v1.2.0"
  #checkov:skip=CKV_TF_1:The checkov is a very restrictive policy and we rely on tags rather than commit hash 
  environment = var.environment
}




locals {
  resourcegroupname = replace(replace(module.naming.resource_group, "<id>", var.unique_id), "<purpose>", var.purpose)
}


resource "azurerm_resource_group" "resource_group" {
  location   = var.location
  managed_by = null
  name       = local.resourcegroupname
  tags       = var.tags
}

