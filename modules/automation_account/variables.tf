variable "aztags" {
  type = map(string)
}

variable "automation_name" {
    type = string
}

variable "automation_location" {
    type = string
}

variable "automation_rg" {
    type = string
}

variable "automation_workspace_id" {
    type = string
}

variable "automation_sku" {
    type = string
    default = "Basic"
}

variable "runbooks" {
    type = list(object({
        name = string
        description = string
        runbook_type = string
        file = string
        frequency = string
        interval = number
        time = string
        week_days = list(string)
        month_days = list(string)
    }))
}