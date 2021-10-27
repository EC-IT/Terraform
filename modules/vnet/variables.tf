variable "aztags" {
  type = map(string)
}

variable "vnet_name" {
    type        = string
    description = "Virtual Network name"
    #default     = "ec-terraformpoc-rg"
}

variable "vnet_location" {
    type        = string
}

variable "vnet_rg" {
    type        = string
}

variable "vnet_address_space" {
    type        = list(any)
}

variable "vnet_dns" {
    type        = list(any)
    default     = ["168.63.129.16"]
}

variable "vnet_subnet" {   
    type = list(object({
        name = string
        cidr = list(string)
        nsg = string
        udr = string
        delegation = string
    }))    
}


variable "vnet_nsg" {
    type = list(object({
    name  = string
    security_rule = list(object({ name = string
                                priority = number
                                direction = string
                                protocol = string
                                dest_port = list(string)
                                src_port = list(string)
                                src_ip = list(string)
                                dest_ip = list(string)
                                access = string
                                description = string
                                }))
  }))
}

variable "vnet_udr" {
    type = list(object({
    name  = string
    route = list(object({ name = string
                          address_prefix = string
                          next_hop_type = string
                          next_hop_in_ip_address = string
                          }))
  }))
}

variable "ase_delegation" {
    type = bool
    default = false
}
