variable "aztags" {
  type = map(string)
}

variable "alerts" {
    type = list(object({
        name = string
        email_subject = string
        description = string
        query = string
        severity = number
        frequency = number
        time_window = number
        threshold = number
        action_group = string
    }))
}

variable "action_group" {
    type = list(object({
        name = string
        email_address = string
        email_name = string
    }))
}

variable "location" {
    type = string
    default = "westeurope"
}

variable "rg_name" {
    type = string
}

variable "insight_id" {
    type = string
}

variable "throttling" {
    type = number
    default = 120
}