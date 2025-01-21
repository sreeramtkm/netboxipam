variable "environment" {
  type        = string
  description = "The environment where the app has to be deployed"

}

variable "resgremotestate" {
  type        = string
  description = "remote state environment"
  default     = "rg-terraform-state"
}


variable "unique_id" {
  type        = string
  description = "The unique id used for naming and identifying the resources"

}



variable "location" {
  type        = string
  description = "The location where the infrastructure needs to be deployed"
}


variable "storage_account_name" {
  type        = string
  description = "The name of the storage account"
}

variable "dnszonename" {
  type        = string
  description = "The dnz zone for the custom domain configuration in the container apps"
}

variable "subdomain" {
  type        = string
  description = "The domain name of the app"
}

variable "purpose" {
  type        = string
  description = "used to identify resource groups and other resources uniquely"
}


variable "managedidentitytype" {
  type        = string
  description = "The type of the managed identity"
  default     = "UserAssigned"
}