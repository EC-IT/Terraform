variable "aztags" {
  type = map(string)
}

variable "ase_name" {
    type = string    
}

variable "ase_rg" {
    type = string    
}

variable "ase_subnet_id" {
    type = string    
}

variable "ase_load_balancing_mode" {
    type = string    
    default = "Web, Publishing"
}

variable "app_plans" {
    type = list(object({
        name = string
        kind = string
        tags = map(string)
        tier = string
        size = string
        capacity = number
    }))
}