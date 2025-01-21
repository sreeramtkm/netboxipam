
data "azurerm_virtual_network" "vnet" {
  name                = replace(module.naming.vnet, "<id>", var.unique_id)
  resource_group_name = local.resourcegroupstateful
}

data "azurerm_subnet" "containerappsubnet" {
  name                 = replace(module.naming.subnet, "<id>", "containerapps")
  resource_group_name  = local.resourcegroupstateful
  virtual_network_name = replace(module.naming.vnet, "<id>", var.unique_id)
}


data "azurerm_user_assigned_identity" "mi" {
  name                = local.managedidentity
  resource_group_name = local.resourcegroupstateful
}

resource "azurerm_container_app_environment" "containerappenv" {
  infrastructure_subnet_id       = data.azurerm_subnet.containerappsubnet.id
  internal_load_balancer_enabled = true
  location                       = var.location
  log_analytics_workspace_id     = null
  name                           = replace(module.naming.containerapp_environment, "<id>", var.unique_id)
  resource_group_name            = azurerm_resource_group.resource_group.name
  tags                           = {}
  zone_redundancy_enabled        = false
  workload_profile {
    name                  = "Consumption"
    workload_profile_type = "Consumption"
  }
}

resource "azurerm_container_app_environment_storage" "rediscacheshare" {
  access_key                   = azurerm_storage_account.sa.primary_access_key
  access_mode                  = "ReadWrite"
  account_name                 = azurerm_storage_account.sa.name
  container_app_environment_id = azurerm_container_app_environment.containerappenv.id
  name                         = "rediscache"
  share_name                   = "rediscache"
}

resource "azurerm_container_app_environment_storage" "redisshare" {
  access_key                   = azurerm_storage_account.sa.primary_access_key
  access_mode                  = "ReadWrite"
  account_name                 = azurerm_storage_account.sa.name
  container_app_environment_id = azurerm_container_app_environment.containerappenv.id
  name                         = "redis"
  share_name                   = "redis"
}

locals {
  mi_list = [data.azurerm_user_assigned_identity.mi.id]
}


module "rediscache" {
  depends_on = [
    azurerm_container_app_environment_storage.rediscacheshare
  ]
  source                       = "../modules/azurecontainerapps/"
  environment                  = var.environment
  envfile                      = jsondecode(file("${path.root}/env_variables/${var.environment}/rediscache.json"))
  secfile                      = jsondecode(file("${path.root}/secrets/${var.environment}/rediscache.json"))
  resource_group_name          = azurerm_resource_group.resource_group.name
  config                       = jsondecode(file("${path.root}/containerconfig/prod/rediscache.json"))
  container_app_environment_id = azurerm_container_app_environment.containerappenv.id
  mi_list                      = local.mi_list
  # mi_type = var.managedidentitytype

}

module "redis" {
  depends_on = [
    azurerm_container_app_environment_storage.redisshare
  ]
  source                       = "../modules/azurecontainerapps/"
  environment                  = var.environment
  envfile                      = jsondecode(file("${path.root}/env_variables/${var.environment}/redis.json"))
  secfile                      = jsondecode(file("${path.root}/secrets/${var.environment}/redis.json"))
  resource_group_name          = azurerm_resource_group.resource_group.name
  config                       = jsondecode(file("${path.root}/containerconfig/prod/redis.json"))
  container_app_environment_id = azurerm_container_app_environment.containerappenv.id
  mi_list                      = local.mi_list
  # mi_type                      = var.managedidentitytype
}

module "netboxworker" {
  depends_on = [
    module.netbox
  ]

  source                       = "../modules/azurecontainerapps/"
  environment                  = var.environment
  envfile                      = jsondecode(file("${path.root}/env_variables/${var.environment}/netboxworker.json"))
  secfile                      = jsondecode(file("${path.root}/secrets/${var.environment}/netboxworker.json"))
  resource_group_name          = azurerm_resource_group.resource_group.name
  config                       = jsondecode(file("${path.root}/containerconfig/prod/netboxworker.json"))
  container_app_environment_id = azurerm_container_app_environment.containerappenv.id
  mi_list                      = local.mi_list
  # mi_type                      = var.managedidentitytype
}

module "netbox" {
  depends_on = [
    module.redis,
    module.rediscache

  ]
  source                       = "../modules/azurecontainerapps/"
  environment                  = var.environment
  envfile                      = jsondecode(file("${path.root}/env_variables/${var.environment}/netbox.json"))
  secfile                      = jsondecode(file("${path.root}/secrets/${var.environment}/netbox.json"))
  resource_group_name          = azurerm_resource_group.resource_group.name
  config                       = jsondecode(file("${path.root}/containerconfig/prod/netbox.json"))
  container_app_environment_id = azurerm_container_app_environment.containerappenv.id
  mi_list                      = local.mi_list
  # mi_type                      = var.managedidentitytype
}

module "netboxhousekeeping" {
  depends_on = [
    module.netbox
  ]
  source                       = "../modules/azurecontainerapps/"
  environment                  = var.environment
  envfile                      = jsondecode(file("${path.root}/env_variables/${var.environment}/netboxhousekeeping.json"))
  secfile                      = jsondecode(file("${path.root}/secrets/${var.environment}/netboxhousekeeping.json"))
  resource_group_name          = azurerm_resource_group.resource_group.name
  config                       = jsondecode(file("${path.root}/containerconfig/prod/netboxhousekeeping.json"))
  container_app_environment_id = azurerm_container_app_environment.containerappenv.id
  mi_list                      = local.mi_list
  # mi_type                      = var.managedidentitytype
}


data "azurerm_dns_zone" "dnszone" {
  name                = var.dnszonename
  resource_group_name = local.resourcegroupstateful
}




resource "azurerm_dns_cname_record" "cname_record" {
  name                = var.subdomain
  zone_name           = data.azurerm_dns_zone.dnszone.name
  resource_group_name = local.resourcegroupstateful
  ttl                 = 500
  record              = module.netbox.fqdn
}


data "azapi_resource" "app_verification_id" {
  resource_id = azurerm_container_app_environment.containerappenv.id
  type        = "Microsoft.App/managedEnvironments@2023-05-01"

  response_export_values = ["properties.customDomainConfiguration.customDomainVerificationId"]
}

locals {
  verificationId = try(jsondecode(data.azapi_resource.app_verification_id.output).properties.customDomainConfiguration.customDomainVerificationId, null)
}

resource "azurerm_dns_txt_record" "txt_record" {
  name                = "asuid.${var.subdomain}"
  zone_name           = data.azurerm_dns_zone.dnszone.name
  resource_group_name = local.resourcegroupstateful
  ttl                 = 300
  record {
    value = local.verificationId
  }
}


resource "time_sleep" "dns_propagation" {
  create_duration = "300s"

  depends_on = [azurerm_dns_txt_record.txt_record, azurerm_dns_cname_record.cname_record]
  # depends_on = [azurerm_dns_txt_record.txt_record, azurerm_dns_a_record.a_record]

  triggers = {
    url            = "${azurerm_dns_cname_record.cname_record.name}.${data.azurerm_dns_zone.dnszone.name}",
    verificationId = local.verificationId,
    record         = azurerm_dns_cname_record.cname_record.record
  }
}


resource "azapi_update_resource" "custom_domain" {
  lifecycle {
    ignore_changes = []
  }
  type        = "Microsoft.App/containerApps@2023-05-01"
  resource_id = module.netbox.app_id

  body = jsonencode({
    properties = {
      configuration = {
        ingress = {
          customDomains = [
            {
              bindingType = "Disabled",
              name        = time_sleep.dns_propagation.triggers["url"],
            }
          ]
        }
      }
    }
  })
}


resource "azapi_resource" "managed_certificate" {
  # depends_on = [time_sleep.dns_propagation, azapi_update_resource.custom_domain]
  depends_on = [time_sleep.dns_propagation]
  type      = "Microsoft.App/ManagedEnvironments/managedCertificates@2023-05-01"
  name      = "${var.environment}-${var.unique_id}-cert"
  parent_id = azurerm_container_app_environment.containerappenv.id
  location  = var.location

  body = jsonencode({
    properties = {
      subjectName             = "${var.subdomain}.${var.dnszonename}"
      domainControlValidation = "CNAME"
    }
  })

  response_export_values = ["*"]
}


resource "azapi_update_resource" "custom_domain_binding" {
  type        = "Microsoft.App/containerApps@2023-05-01"
  resource_id = module.netbox.app_id

  body = jsonencode({
    properties = {
      configuration = {
        ingress = {
          customDomains = [
            {
              bindingType   = "SniEnabled",
              name          = time_sleep.dns_propagation.triggers["url"],
              certificateId = jsondecode(azapi_resource.managed_certificate.output).id
            }
          ]
        }
      }
    }
  })
}

