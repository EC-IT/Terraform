variable "app_service_name" {
    type        = string
}

variable "app_service_location" {
    type        = string
    default = "West Europe"
}

variable "app_service_resource_group" {
    type        = string
}

variable "app_service_plan_name" {
    type        = string
}

variable "app_service_plan_rg_name" {
    type        = string
}

variable "app_service_dotnet_version" {
    type        = string
    default     = "v6.0"
}

variable "app_service_always_on" {
    type        = bool
    default     = true
}

variable "app_service_aspnetcore_environment" {
    type        = string
}

variable "app_service_tag_environment" {
    type = string
}

variable "app_service_tag_application" {
    type = string
}

variable "app_service_enable_backend" {
    type        = bool
    default     = false
}

variable "app_service_backup_enable" {
    type        = bool
    default     = false
}

variable "app_service_backup_sa_name" {
    type        = string
    default     = ""
}
variable "app_service_backup_sa_rg" {
    type        = string
    default     = ""
}
variable "app_service_domain" {
    type        = list(string)
    default     = []
}

variable "app_service_enable_manage_identity" {
    type        = bool
    default     = false
}

variable "app_service_enable_logs_blob" {
    type        = bool
    default     = false
}

variable "app_service_logs_retention" {
    type        = number
    default     = 365
}

variable "app_service_logs_sa_name" {
    type        = string
    default     = ""
}

variable "app_service_logs_sa_rg" {
    type        = string
    default     = ""
}

variable "app_service_enable_busworker" {
    type        = bool
    default     = false
}

variable "app_service_enable_services" {
    type        = bool
    default     = false
}

variable "app_service_certificate_file" {
    type        = string
    default     = ""
}

variable "app_service_cert_kv_name" {
    type       = string
    default    = ""
}

variable "app_service_cert_kv_rg" {
    type       = string
    default    = ""
}

variable "app_service_cert_kv_secret" {
    type       = string
    default    = "webapp-cert-password"
}

variable "app_service_health_check_enable" {
    type        = bool
    default     = false
}

variable "app_service_health_check_path" {
    type       = string
    default    = "/"
}

variable "app_service_path_mappings" {
    type       = list(object({
                    virtual_path = string
                    physical_path = string
                    preload = bool
    }))
    default    = []
}

variable "app_service_dynatrace_monitored" {
    type       = string
    default    = "true"
}
