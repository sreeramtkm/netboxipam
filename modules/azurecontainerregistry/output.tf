output "container_registry_id" {
  description = "The ID of the Container Registry"
  value       = azurerm_container_registry.main.id
}

output "container_registry_login_server" {
  description = "The URL that can be used to log into the container registry"
  value       = azurerm_container_registry.main.login_server
}

