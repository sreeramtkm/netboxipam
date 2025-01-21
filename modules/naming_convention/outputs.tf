output "ad" {
  value = "ad-<id>-${var.environment}-<num>"
}

output "vnet" {
  value = "vnet-<id>-${var.environment}"
}

output "acr" {
  value = "acr-<id>-${var.environment}-<num>"
}

output "containerapp" {
  value = "ca-<id>-${var.environment}"
}

output "postgresqldb" {
  value = "pg-<id>-${var.environment}"
}

output "subnet" {
  value = "subnet-<id>-${var.environment}"
}

output "containerapp_environment" {
  value = "cae-<id>-${var.environment}"
}

output "dns_zone_hostname" {
  value = "dnsz-<id>-${var.environment}-<num>"
}

output "resource_group" {
  value = "rg-<id>-${var.environment}-<purpose>"
}

output "storage_account_name" {
  value = "sa<id>${var.environment}"
}

output "managed_identity" {
  value = "mi-<id>-${var.environment}-<purpose>"
}