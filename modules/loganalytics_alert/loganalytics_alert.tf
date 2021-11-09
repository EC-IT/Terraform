
resource "azurerm_monitor_scheduled_query_rules_alert" "alerts" {
  for_each            = { for a in var.alerts : a.name => a}
  name                = each.key
  location            = var.location
  resource_group_name = var.rg_name

  action {
    action_group           = [azurerm_monitor_action_group.ecadmingroup[each.value.action_group].id]    
    email_subject          = each.value.email_subject
    #custom_webhook_payload = "{}"
  }

  data_source_id = var.insight_id
  description    = each.value.description
  enabled        = true
  query       = each.value.query
  severity    = each.value.severity
  frequency   = each.value.frequency
  time_window = each.value.time_window

  trigger {
    operator  = "GreaterThan"
    threshold = each.value.threshold
  }
  throttling  = var.throttling
}

resource "azurerm_monitor_action_group" "ecadmingroup" {
  for_each            = { for a in var.action_group : a.name => a }
  name                = each.key
  resource_group_name = var.rg_name
  short_name          = each.key

  email_receiver {
    name          = each.value.email_name
    email_address = each.value.email_address
  }
}

output "action_id" {
    value = tomap({
    for a in azurerm_monitor_action_group.ecadmingroup : a.name => a.id
  })
}