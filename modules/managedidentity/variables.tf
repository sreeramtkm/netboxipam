variable "resourcegroupname" {
  type        = string
  description = "The name of the resource group where the infra is deployed"
}

variable "environment" {
  type        = string
  description = "The environment where the app has to be deployed"
}

variable "unique_id" {
  type        = string
  description = "The unique id used for naming and identifying the resources"
}

variable "purpose" {
  type        = string
  description = "purpose for the resource group"
}

variable "location" {
  type        = string
  description = "The location where the infrastructure will be deployed"
}
