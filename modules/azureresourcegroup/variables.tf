variable "tags" {
  description = "Extra tags to add."
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "The environment where the app has to be deployed"
  type        = string

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
  description = "purpose for the resource group"
  default     = "norwayeast"
}


