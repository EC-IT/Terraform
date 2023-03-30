variable "aztags" {
  type = map(string)
}

variable "storage_account_name" {
    type        = string
}

variable "resource_group_name" {
    type        = string
}

variable "storage_account_location" {
    type        = string
}

variable "sa_account_tier" {
    type        = string
    default     = "Standard"
}

variable "sa_replication_type" {
    type        = string
    default     = "GRS"
}

variable "sa_account_kind" {
    type        = string
    default     = "StorageV2"
}

variable "enable_private_endpoint" {
    type        = bool
    default     = false
}

variable "pe_vnet_name" {
    type        = string    
}

variable "pe_vnet_rg" {
    type        = string    
}

variable "pe_subnet_name" {
    type        = string    
}

variable "enable_network_rules" {
    type        = bool  
    default     = true  
}

variable "pe_dnz_zone_name" {
    type        = string    
}

variable "pe_dnz_zone_rg" {
    type        = string    
}

variable "pe_subresource" {
    type        = string
    default     = "file"
    validation {
        condition     = contains(["blob", "file", "queue", "table", "web"], var.pe_subresource)
        error_message = "Valid values for pe_subresource are blob, file, queue and table."
  } 
}
/*
variable "tag_ec_application" {
    type        = string
    validation {
        condition     = length(var.tag_ec_application) > 0
        error_message = "Tag EC_APPLICATION must be set."
        }
}

variable "tag_ec_environment" {
    type        = string
    validation {
        condition     = length(var.tag_ec_environment) > 2 && length(var.tag_ec_environment) < 12
        error_message = "Tag EC_ENVIRONMENT must be \"DEV\", \"PPD\" or \"PROD\" ."
        }
}
*/
