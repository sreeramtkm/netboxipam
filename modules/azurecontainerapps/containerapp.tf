

variable "resource_group_name" {
  type        = string
  description = "The config file name of the configuration"

}
variable "mi_list" {
  type        = list(string)
  description = "List of managed identities"
}

variable "location" {
  type        = string
  description = "The location where the container app has to be deployed"
}

variable "envfile" {
  type = list(object({
    name        = string
    value       = optional(string)
    secret_name = optional(string)
  }))
  description = "The environment variables for the container"
  default     = []

}

variable "secfile" {
  type = list(object({
    name                = optional(string)
    value               = optional(string)
    identity            = optional(string)
    key_vault_secret_id = optional(string)
  }))
  description = "The secrets for the app"
  default     = []
}

variable "container_app_environment_id" {
  type        = string
  description = "The container app environment id "
}

variable "unique_id" {
  type        = string
  description = "The unique id used for naming and identifying the resources"
}


variable "config" {
  type = object({
    basicproperties = object({
      container_name        = string
      revision_mode         = string
      workload_profile_name = string

    })
    customdomain = optional(object({
      hostname            = string
      zonename            = string
      resourcegroupfordns = string
      customdomainfix     = number
    }))
    registry = optional(object({
      server               = string
      identity             = optional(string)
      password_secret_name = optional(string)
      username             = optional(string)
    }))
    ingress = optional(object({
      allow_insecure_connections = optional(bool)
      external_enabled           = optional(bool)
      target_port                = number
      transport                  = optional(string)
    }))
    configtemplate = object({
      max_replicas = number
      min_replicas = number
      container = object({
        args    = list(string)
        command = list(string)
        cpu     = number
        image   = string
        memory  = string
        name    = string
        volume_mounts = optional(object({
          name = optional(string)
          path = optional(string)
      })) })
      volume = optional(object({
        name         = optional(string)
        storage_name = optional(string)
        storage_type = optional(string)
    })) })
  })
}




variable "environment" {
  type        = string
  description = "The environment where the app has to be deployed"

}

module "naming" {
  source = "git::https://ngi001@dev.azure.com/ngi001/digital-services-config/_git/terraformmodules?ref=naming_convention/v1.2.0"
  #checkov:skip=CKV_TF_1:The checkov is a very restrictive policy and we rely on tags rather than commit hash 
  environment = var.environment
}

locals {
  secrets             = length(var.secfile) != 0 ? var.secfile : []
  create_customdomain = try(var.config.customdomain, "donotexists") == "donotexists" ? 0 : 1
  customdomain        = (local.create_customdomain == 1) && (var.config.customdomain.customdomainfix == 1) ? 1 : 0
}


resource "azurerm_container_app" "containerapp" {
  container_app_environment_id = var.container_app_environment_id
  lifecycle {
    ignore_changes = [ingress[0].custom_domain]
  }
  name                  = replace(module.naming.containerapp, "<id>", var.config.basicproperties.container_name)
  resource_group_name   = var.resource_group_name
  revision_mode         = var.config.basicproperties.revision_mode
  tags                  = {}
  workload_profile_name = var.config.basicproperties.workload_profile_name
  identity {
    type         = "UserAssigned"
    identity_ids = var.mi_list
  }
  registry {
    server   = try(var.config.registry.server, null)
    identity = try(var.mi_list[0], null)
  }
  dynamic "secret" {
    for_each = local.secrets
    content {
      name                = try(secret.value.name, null)
      identity            = try(secret.value.identity, null)
      key_vault_secret_id = try(secret.value.key_vault_secret_id, null)
      value               = try(secret.value.value, null)
    }
  }
  dynamic "ingress" {
    for_each = var.config.ingress != null ? [var.config.ingress] : []
    content {
      allow_insecure_connections = try(ingress.value.allow_insecure_connections, null)
      external_enabled           = try(ingress.value.external_enabled, null)
      target_port                = try(ingress.value.target_port, null)
      transport                  = try(ingress.value.transport, null)
      traffic_weight {
        label           = null
        latest_revision = true
        percentage      = 100
        revision_suffix = null
      }
    }
  }
  template {
    max_replicas    = var.config.configtemplate.max_replicas
    min_replicas    = var.config.configtemplate.min_replicas
    revision_suffix = null
    container {
      args    = var.config.configtemplate.container.args
      command = var.config.configtemplate.container.command
      cpu     = var.config.configtemplate.container.cpu
      image   = var.config.configtemplate.container.image
      memory  = var.config.configtemplate.container.memory
      name    = var.config.configtemplate.container.name
      dynamic "env" {
        for_each = { for env in var.envfile : env.name => env }
        content {
          name        = env.value.name
          value       = try(env.value.value, null)
          secret_name = try(env.value.secret_name, null)
        }
      }
      dynamic "volume_mounts" {
        for_each = var.config.configtemplate.container.volume_mounts != null ? [var.config.configtemplate.container.volume_mounts] : []
        content {
          name = try(volume_mounts.value.name, null)
          path = try(volume_mounts.value.path, null)
        }
      }
    }
    dynamic "volume" {
      for_each = var.config.configtemplate.volume != null ? [var.config.configtemplate.volume] : []
      content {
        name         = try(volume.value.name, null)
        storage_name = try(volume.value.storage_name, null)
        storage_type = try(volume.value.storage_type, null)
      }
    }

  }
}


data "azurerm_dns_zone" "dnszone" {
  count               = local.create_customdomain
  name                = var.config.customdomain.zonename
  resource_group_name = var.config.customdomain.resourcegroupfordns
}




resource "azurerm_dns_cname_record" "cname_record" {
  count               = local.create_customdomain
  name                = var.config.customdomain.hostname
  zone_name           = var.config.customdomain.zonename
  resource_group_name = var.config.customdomain.resourcegroupfordns
  ttl                 = 500
  record              = azurerm_container_app.containerapp.ingress[0].fqdn
}

data "azapi_resource" "app_verification_id" {
  count       = local.create_customdomain
  resource_id = var.container_app_environment_id
  type        = "Microsoft.App/managedEnvironments@2023-05-01"

  response_export_values = ["properties.customDomainConfiguration.customDomainVerificationId"]
}

# locals {
#   verificationId = try(jsondecode(data.azapi_resource.app_verification_id.output).properties.customDomainConfiguration.customDomainVerificationId, null)
# }

resource "azurerm_dns_txt_record" "txt_record" {
  count               = local.create_customdomain
  name                = "asuid.${var.config.customdomain.hostname}"
  zone_name           = var.config.customdomain.zonename
  resource_group_name = var.config.customdomain.resourcegroupfordns
  ttl                 = 300
  record {
    value = jsondecode(data.azapi_resource.app_verification_id[count.index].output).properties.customDomainConfiguration.customDomainVerificationId
  }
}


resource "time_sleep" "dns_propagation" {
  count           = local.create_customdomain
  create_duration = "300s"

  depends_on = [azurerm_dns_txt_record.txt_record, azurerm_dns_cname_record.cname_record]
  # depends_on = [azurerm_dns_txt_record.txt_record, azurerm_dns_a_record.a_record]

  triggers = {
    url            = "${azurerm_dns_cname_record.cname_record[count.index].name}.${data.azurerm_dns_zone.dnszone[count.index].name}",
    verificationId = jsondecode(data.azapi_resource.app_verification_id[count.index].output).properties.customDomainConfiguration.customDomainVerificationId,
    record         = azurerm_dns_cname_record.cname_record[count.index].record
  }
}


resource "azapi_update_resource" "custom_domain" {
  count = local.customdomain
  lifecycle {
    ignore_changes = []
  }
  type        = "Microsoft.App/containerApps@2023-05-01"
  resource_id = azurerm_container_app.containerapp.id

  body = jsonencode({
    properties = {
      configuration = {
        ingress = {
          customDomains = [
            {
              bindingType = "Disabled",
              name        = time_sleep.dns_propagation[count.index].triggers["url"],
            }
          ]
        }
      }
    }
  })
}

resource "azapi_resource" "managed_certificate" {
  count      = local.create_customdomain
  depends_on = [time_sleep.dns_propagation, azapi_update_resource.custom_domain]
  # depends_on = [time_sleep.dns_propagation]
  type      = "Microsoft.App/ManagedEnvironments/managedCertificates@2023-05-01"
  name      = "${var.environment}-${var.unique_id}-cert"
  parent_id = var.container_app_environment_id
  location  = var.location

  body = jsonencode({
    properties = {
      subjectName             = "${var.config.customdomain.hostname}.${var.config.customdomain.zonename}"
      domainControlValidation = "CNAME"
    }
  })

  response_export_values = ["*"]
}


resource "azapi_update_resource" "custom_domain_binding" {
  count       = local.create_customdomain
  type        = "Microsoft.App/containerApps@2023-05-01"
  resource_id = azurerm_container_app.containerapp.id

  body = jsonencode({
    properties = {
      configuration = {
        ingress = {
          customDomains = [
            {
              bindingType   = "SniEnabled",
              name          = time_sleep.dns_propagation[count.index].triggers["url"],
              certificateId = jsondecode(azapi_resource.managed_certificate[count.index].output).id
            }
          ]
        }
      }
    }
  })
}

