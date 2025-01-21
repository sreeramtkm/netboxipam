variable "resourcegroupname" {
  description = "A container that holds related resources for an Azure solution"
  type        = string
  default     = ""
}

variable "location" {
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  default     = ""
  type        = string
}

variable "container_registry_config" {
  description = "Manages an Azure Container Registry"
  type = object({
    name                          = string
    admin_enabled                 = optional(bool)
    sku                           = optional(string)
    public_network_access_enabled = optional(bool)
    quarantine_policy_enabled     = optional(bool)
    zone_redundancy_enabled       = optional(bool)
  })
}

variable "retentiondays" {
  type    = number
  default = 7
}
