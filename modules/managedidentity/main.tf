module "naming" {
  source = "git::https://ngi001@dev.azure.com/ngi001/digital-services-config/_git/terraformmodules?ref=naming_convention/v1.2.0"
  #checkov:skip=CKV_TF_1:The checkov is a very restrictive policy and we rely on tags rather than commit hash 
  environment = var.environment
}



resource "azurerm_user_assigned_identity" "mi" {
  location            = var.location
  name                = replace(replace(module.naming.managed_identity, "<id>", var.unique_id), "<purpose>", var.purpose)
  resource_group_name = var.resourcegroupname
}