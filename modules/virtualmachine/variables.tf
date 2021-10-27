variable "subnet_name" {
  type = string
}

variable "vm_name" {
  type = string
}

variable "vm_location" {
  type    = string
  default = "West Europe"
}

variable "resource_group_name" {
  type = string
}

variable "key_vault_name" {
  type = string
}

variable "key_vault_rg" {
  type = string
}

variable "secret_username" {
  type = string
}

variable "secret_password" {
  type = string
}

variable "vnet_name" {
  type = string
}

variable "vnet_rg" {
  type = string
}

variable "backup_policy_name" {
  type = string
}

variable "recovery_vault_name" {
  type = string
}

variable "backup_policy_rg" {
  type = string
}

variable "ip_address" {
  type = string
}

variable "vm_priority" {
  type    = string
  default = "Regular"
}

variable "vm_zone" {
  type    = string
  default = "1"
}

variable "enable_backup" {
  type    = bool
  default = true
}

variable "vm_accelerated_networking" {
  type    = string
  default = "true"
}

variable "vm_size" {
  type = string
  validation {
    condition     = length(var.vm_size) > 2
    error_message = "VM size must be set."
  }
}

variable "tag_ec_application" {
  type = string
  validation {
    condition     = length(var.tag_ec_application) > 0
    error_message = "Tag EC_APPLICATION must be set."
  }
}

variable "tag_ec_environment" {
  type = string
  validation {
    condition     = length(var.tag_ec_environment) > 2 && length(var.tag_ec_environment) < 12
    error_message = "Tag EC_ENVIRONMENT must be \"DEV\", \"PPD\" or \"PROD\" ."
  }
}

variable "disks" {
  type    = list(any)
  default = []
}

variable "disks_account_type" {
  type    = string
  default = "Premium_LRS"
}

variable "licence_hybrid_benefit" {
  type    = bool
  default = false
}

variable "keyvault_bitlocker" {
  type    = string
  default = ""
}

variable "keyvault_bitlocker_rg" {
  type    = string
  default = ""
}

variable "disk_encryption" {
  type    = bool
  default = false
}

variable "keyname" {
  type    = string
  default = ""
}

variable "keyversion" {
  type    = string
  default = ""
}

variable "subscription_id" {
  type    = string
  default = ""
}

variable "vm_diag_enable" {
  type    = bool
  default = false
}

variable "vm_diag_sa" {
  type    = string
  default = ""
}

variable "vm_diag_sa_rg" {
  type    = string
  default = ""
}

variable "loganalytics_workspace" {
  type    = string
  default = "ECLogAnalyticsWorkspace"
}

variable "loganalytics_workspace_rg" {
  type    = string
  default = "ec_prod_core"
}
