variable "environment" {
  type        = string
  description = "The environment where the app has to be deployed"
  default     = "test"
}

variable "dnszone" {
  type        = string
  description = "The name of the DNS zone which will host the domain records"
}

variable "unique_id" {
  type        = string
  description = "The unique id that is used to distinguish resource groups , resources etc"
}

variable "dbname" {
  type        = string
  description = "The name of the database"
}

variable "dbuser" {
  type        = string
  description = "The database user"
}

variable "dbpassword" {
  type        = string
  description = "The environment where the app has to be deployed"
}

variable "location" {
  type        = string
  description = "The environment where the app has to be deployed"
}

variable "db_sku_name" {
  type        = string
  description = "The environment where the app has to be deployed"
}

variable "storage_tier" {
  type        = string
  description = "The environment where the app has to be deployed"
}

variable "db_version" {
  type        = string
  description = "The environment where the app has to be deployed"
}

variable "purpose" {
  type        = string
  description = "The environment where the app has to be deployed"
}

variable "proxydnszone" {
  type        = string
  description = "The environment where the app has to be deployed"
}

variable "vnetipaddressrange" {
  type        = string
  description = "The environment where the app has to be deployed"
}

variable "subnetlist" {
  type        = list(string)
  description = "The environment where the app has to be deployed"
}









