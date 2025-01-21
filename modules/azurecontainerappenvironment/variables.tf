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


variable "location" {
  type        = string
  description = "The location where the infrastructure will be deployed"
}

variable "subnetid" {
  type        = string
  description = "The subnet where the container app environment needs to be deployed . This is a delegated subnet"
  nullable    = true
  default     = ""
}

variable "internal_loadbalancer_enabled" {
  type        = bool
  description = "The subnet where the container app environment needs to be deployed . This is a delegated subnet"
  nullable    = true
  default     = false
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "The subnet where the container app environment needs to be deployed . This is a delegated subnet"
  nullable    = true
  default     = ""
}

variable "tags" {
  description = "Extra tags to add."
  type        = map(string)
  default     = {}
}

variable "zone_redundancy_enabled" {
  description = "Should the Container App Environment be created with Zone Redundancy enabled? Defaults to false"
  type        = bool
  default     = false
}

variable "workload_profile_name" {
  description = "Workload profile type for the workloads to run on"
  type        = string
  default     = "Consumption"
}

variable "workload_profile_type" {
  description = "Workload profile type for the workloads to run on"
  type        = string
  default     = "Consumption"
}