resource "azurerm_postgresql_flexible_server" "dbprivatenew" {
  administrator_login               = var.dbuser
  administrator_password            = var.dbpassword
  auto_grow_enabled                 = false
  backup_retention_days             = 7
  create_mode                       = null
  delegated_subnet_id               = azurerm_subnet.dbsubnet.id
  geo_redundant_backup_enabled      = false
  location                          = var.location
  name                              = replace(module.naming.postgresqldb, "<id>", var.unique_id)
  point_in_time_restore_time_in_utc = null
  private_dns_zone_id               = azurerm_private_dns_zone.privatezone.id
  public_network_access_enabled     = false
  replication_role                  = null
  resource_group_name               = azurerm_resource_group.rg.name
  sku_name                          = var.db_sku_name
  source_server_id                  = null
  storage_mb                        = 32768
  storage_tier                      = var.storage_tier
  tags                              = {}
  version                           = var.db_version
  zone                              = 1
  authentication {
    active_directory_auth_enabled = false
    password_auth_enabled         = true
    tenant_id                     = null
  }
}

resource "azurerm_postgresql_flexible_server_configuration" "sslturnoff" {
  name      = "require_secure_transport"
  server_id = azurerm_postgresql_flexible_server.dbprivatenew.id
  value     = "off"
}



resource "azurerm_private_dns_zone" "privatezone" {
  name                = "${local.dbname}.private.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
  tags                = {}

}


resource "azurerm_private_dns_zone_virtual_network_link" "ipamdb" {
  name                  = "${local.dbname}.private.postgres.database.azure.com"
  private_dns_zone_name = azurerm_private_dns_zone.privatezone.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  resource_group_name   = azurerm_resource_group.rg.name
  depends_on            = [azurerm_subnet.dbsubnet]
}
