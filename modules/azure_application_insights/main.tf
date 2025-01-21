resource "azurerm_application_insights" "app_insights_workspace" {
  name                       = var.app_insights_name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  workspace_id               = data.azurerm_log_analytics_workspace.log_analytics_workspace.id
  application_type           = var.app_insights_type
  internet_ingestion_enabled = try(var.app_insights_internet_ingestion_enabled, null)
  internet_query_enabled     = try(var.app_insights_internet_query_enabled, null)
}