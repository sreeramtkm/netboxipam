resource "azurerm_user_assigned_identity" "mi" {
  location            = azurerm_resource_group.rg.location
  name                = replace(replace(module.naming.managed_identity, "<id>", var.unique_id), "<purpose>", var.purpose)
  resource_group_name = azurerm_resource_group.rg.name
}