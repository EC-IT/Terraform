variable "aks_name" {
    type        = string
}

variable "aks_resource_group" {
    type        = string
}

variable "aks_vnet_name" {
    type        = string
}

variable "aks_subnet_name" {
    type        = string
}

variable "aks_subnet_resource_group" {
    type        = string
}
variable "aks_node_resource_group" {
    type        = string
}

variable "aks_agent_admin_group" {
    type        = list(string)
}

variable "aks_agent_pool_name" {
    type        = string
    default     = "agentpool"
}

variable "aks_agent_pool_vm_size" {
    type        = string
    default     = "Standard_D2_v2"
}

variable "aks_agent_pool_node_count" {
    type        = number
    default     = 1
}

variable "aks_agent_pool_max_pods" {
    type        = number
    default     = 30
}

variable "aks_agent_pool_max_count" {
    type        = number
    default     = 2
}

variable "aks_agent_pool_min_count" {
    type        = number
    default     = 1
}

variable "aks_agent_pool_zones" {
    type        = list(number)
    default     = [1,2]
}

variable "aks_agent_nodes" {
    type       = list(object({
                    name = string
                    vm_size = string
                    node_count = number
                    max_count = number
                    min_count = number
                    max_pods = number
                    #subnet = string
    }))
    default     = []
}

variable "aks_agent_tags" {
    type        = map(any)
    default     = {}
}

variable "aks_dns_zone_enable" {
    type        = bool
    default     = false
}

variable "aks_dns_zone_name" {
    type        = string
    default     = "privatelink.westeurope.azmk8s.io"
}

variable "aks_dns_zone_rg" {
    type        = string
    default     = ""
}
variable "aks_assigned_identity_enable" {
    type        = bool
    default     = false
}
variable "aks_assigned_identity_name" {
    type        = string
    default     = ""
}
variable "aks_assigned_identity_rg" {
    type        = string
    default     = ""
}

variable "aks_sku" {
    type        = string
    default     = "Free"
}
