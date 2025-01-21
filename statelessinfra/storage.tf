
locals {
  resourcegroupname     = replace(replace(module.naming.resource_group, "<id>", var.unique_id), "<purpose>", var.purpose)
  resourcegroupstateful = replace(replace(module.naming.resource_group, "<id>", var.unique_id), "<purpose>", "stateful")
  managedidentity       = replace(replace(module.naming.managed_identity, "<id>", var.unique_id), "<purpose>", "stateful")
}




module "naming" {
  source = "../modules/naming_convention/"
  environment = var.environment
  # also any inputs for the module (see below)
}



resource "azurerm_resource_group" "resource_group" {
  location   = var.location
  managed_by = null
  name       = local.resourcegroupname
  tags       = {}
}



resource "azurerm_storage_account" "sa" {
  access_tier                       = "Hot"
  account_kind                      = "StorageV2"
  account_replication_type          = "LRS"
  account_tier                      = "Standard"
  infrastructure_encryption_enabled = false
  is_hns_enabled                    = true
  large_file_share_enabled          = true
  local_user_enabled                = true
  location                          = var.location
  min_tls_version                   = "TLS1_2"
  name                              = replace(module.naming.storage_account_name, "<id>", var.storage_account_name)
  nfsv3_enabled                     = false
  public_network_access_enabled     = true
  queue_encryption_key_type         = "Service"
  resource_group_name               = azurerm_resource_group.resource_group.name
  sftp_enabled                      = false
  shared_access_key_enabled         = true
  table_encryption_key_type         = "Service"
  tags                              = {}
}


resource "azurerm_storage_share" "rediscache" {
  name                 = "rediscache"
  storage_account_name = azurerm_storage_account.sa.name
  quota                = 1
  access_tier          = "Hot"

  acl {
    id = "rediscacheshare"
    access_policy {
      permissions = "rwdl"
    }
  }
}


resource "azurerm_storage_share" "redis" {
  name                 = "redis"
  storage_account_name = azurerm_storage_account.sa.name
  quota                = 1
  access_tier          = "Hot"

  acl {
    id = "redis"

    access_policy {
      permissions = "rwdl"
    }
  }
}






