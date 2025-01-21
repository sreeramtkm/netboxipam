
module "naming" {
  source = "git::https://ngi001@dev.azure.com/ngi001/digital-services-config/_git/terraformmodules?ref=naming_convention/v1.2.0"
  #checkov:skip=CKV_TF_1:The checkov is a very restrictive policy and we rely on tags rather than commit hash 
  environment = var.environment
}



resource "azurerm_container_app_environment" "containerappenv" {
  infrastructure_subnet_id       = var.subnetid == "" ? null : var.subnetid
  internal_load_balancer_enabled = var.subnetid == "" ? null : var.internal_loadbalancer_enabled
  location                       = var.location
  log_analytics_workspace_id     = var.log_analytics_workspace_id == "" ? null : var.log_analytics_workspace_id
  name                           = replace(module.naming.containerapp_environment, "<id>", var.unique_id)
  resource_group_name            = var.resourcegroupname
  tags                           = var.tags
  zone_redundancy_enabled        = var.subnetid == "" ? null : var.zone_redundancy_enabled
  workload_profile {
    name                  = var.workload_profile_name
    workload_profile_type = var.workload_profile_type

  }
}