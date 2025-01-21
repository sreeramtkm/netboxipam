locals {
  retentiondays = var.container_registry_config.sku == "Basic" ? 0 : var.retentiondays
}

resource "azurerm_container_registry" "main" {
  #checkov:skip=CKV_AZURE_163:Since currently we are not using vulnerability solution disabling the same.Create a new version based on reqmts in future
  #checkov:skip=CKV_AZURE_233:Saving cost by not making ACR redundant. Create a new version based on reqmts in future
  #checkov:skip=CKV_AZURE_237:Saving cost by not enabling dedicated endpoints. Create a new version based on reqmts in future
  #checkov:skip=CKV_AZURE_165:No Geo-Replicated container registry needed. Create a new version based on reqmts in future
  #checkov:skip=CKV_AZURE_164:This version of ACR does not necessitate signed images.Create a new version based on reqmts in future 
  name                          = format("%s", var.container_registry_config.name)
  resource_group_name           = var.resourcegroupname
  location                      = var.location
  admin_enabled                 = var.container_registry_config.admin_enabled
  sku                           = var.container_registry_config.sku
  public_network_access_enabled = var.container_registry_config.public_network_access_enabled
  quarantine_policy_enabled     = var.container_registry_config.quarantine_policy_enabled
  zone_redundancy_enabled       = var.container_registry_config.zone_redundancy_enabled
  anonymous_pull_enabled        = false
  retention_policy {
    enabled = local.retentiondays == 0 ? false : true
    days    = local.retentiondays
  }
}
