output "fqdn" {
  value = try(azurerm_container_app.containerapp.ingress[0].fqdn, null)
}

output "app_id" {
  value = try(azurerm_container_app.containerapp.id, null)
}

output "ipaddress" {
  value = try(azurerm_container_app.containerapp.id, null)
}

