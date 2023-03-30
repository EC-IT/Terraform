
resource "azurerm_automation_account" "automation_account" {
  name                = var.automation_name
  location            = var.automation_location
  resource_group_name = var.automation_rg
  sku_name            = var.automation_sku

  tags                = var.aztags
}

resource "azurerm_log_analytics_linked_service" "automationlink" {
  resource_group_name = azurerm_automation_account.automation_account.resource_group_name
  workspace_id        = var.automation_workspace_id
  read_access_id      = azurerm_automation_account.automation_account.id
}


data "local_file" "runbook_files" {
  for_each = {for r in var.runbooks : r.name => r }
  filename = "${path.module}/../../${each.value.file}"
}

resource "azurerm_automation_runbook" "automation_runbook" {  
  for_each = {for r in var.runbooks : r.name => r }
  name                    = each.key
  location                = azurerm_automation_account.automation_account.location
  resource_group_name     = azurerm_automation_account.automation_account.resource_group_name
  automation_account_name = azurerm_automation_account.automation_account.name
  log_verbose             = "false"
  log_progress            = "false"
  description             = each.value.description
  runbook_type            = each.value.runbook_type

  content = data.local_file.runbook_files[each.key].content
}

resource "time_offset" "tomorrow" {
  offset_days = 1
}

locals {
  update_time = "23:00"
  update_date = substr(time_offset.tomorrow.rfc3339, 0, 10)
  update_timezone = "UTC"
}

resource "azurerm_automation_schedule" "automation_schedule" {
  for_each = {for r in var.runbooks : r.name => r }
  name                    = "${each.key}_schedule"
  resource_group_name     = azurerm_automation_account.automation_account.resource_group_name
  automation_account_name = azurerm_automation_account.automation_account.name
  frequency               = each.value.frequency
  interval                = each.value.interval
  week_days               = each.value.interval == "Week" ? each.value.week_days : null
  month_days              = each.value.interval == "Month" ? each.value.month_days : null  
  
  timezone                = "Europe/Paris"
  start_time              = "${local.update_date}T${each.value.time}:00+02:00"
}

resource "azurerm_automation_job_schedule" "job_schedule" {
  for_each = {for r in var.runbooks : r.name => r }
  resource_group_name     = azurerm_automation_account.automation_account.resource_group_name
  automation_account_name = azurerm_automation_account.automation_account.name
  runbook_name            = each.key
  schedule_name           = azurerm_automation_schedule.automation_schedule[each.key].name
}