
resource "azurerm_log_analytics_datasource_windows_performance_counter" "performancecounter" {
  count               = length(var.performance_counters)
  name                = "${var.performance_counters[count.index].name}-${count.index}"
  resource_group_name = var.rg_name
  workspace_name      = var.workspace_name
  object_name         = var.performance_counters[count.index]["name"]
  instance_name       = "*"
  counter_name        = var.performance_counters[count.index]["counter_name"]
  interval_seconds    = var.performance_counters[count.index]["interval_seconds"]
}

resource "azurerm_log_analytics_datasource_windows_event" "windowsevent" {
  for_each            = { for e in var.windows_events: e.event_log_name => e}
  name                = each.key
  resource_group_name = var.rg_name
  workspace_name      = var.workspace_name
  event_log_name      = each.key
  event_types         = each.value.event_types
}