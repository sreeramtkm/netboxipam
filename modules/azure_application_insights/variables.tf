variable "app_insights_name" {
  type        = string
  description = "The app insights name."
}

variable "app_insights_type" {
  type        = string
  description = "The app insights type."
}

variable "app_insights_internet_ingestion_enabled" {
  type        = string
  description = "app insights internet ingestion enabled"
}

variable "app_insights_internet_query_enabled" {
  type        = string
  description = "app insights internet query enabled"
}

variable "location" {
  type        = string
  description = "location."
}

variable "resource_group_name" {
  type        = string
  description = "resource group name."
}