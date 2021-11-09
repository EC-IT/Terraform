
variable "performance_counters" {
    type = list(object({
        name = string
        counter_name = string
        interval_seconds = number
    }))
}

variable "windows_events" {
    type = list(object({
        event_log_name = string
        event_types = list(string)
    }))
}

variable "rg_name" {
    type = string
}

variable "workspace_name" {
    type = string
}
