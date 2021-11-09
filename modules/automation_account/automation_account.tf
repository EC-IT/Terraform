
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
  for_each                = var.create_job_schedule ? {for r in var.runbooks : r.name => r } : {}
  resource_group_name     = azurerm_automation_account.automation_account.resource_group_name
  automation_account_name = azurerm_automation_account.automation_account.name
  runbook_name            = each.key
  schedule_name           = azurerm_automation_schedule.automation_schedule[each.key].name

  lifecycle {
    ignore_changes = [
      job_schedule_id
    ]
  }
}



# Add Updates workspace solution to log analytics if enable_update_management is set to true.
resource "azurerm_log_analytics_solution" "law_solution_updates" {
  count                 = "${var.enable_update_management ? 1 : 0}"
  resource_group_name   = azurerm_automation_account.automation_account.resource_group_name
  location              = azurerm_automation_account.automation_account.location
  solution_name         = "Updates"
  workspace_resource_id = var.automation_workspace_id
  workspace_name        = "${element(split("/", var.automation_workspace_id), length(split("/", var.automation_workspace_id)) - 1)}"

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/Updates"
  }
}

# Send logs to Log Analytics # Required for automation account with update management enabled.
resource "azurerm_monitor_diagnostic_setting" "aa_diags_logs" {
  count                      = "${var.enable_update_management ? 1 : 0}"
  name                       = "LogsToLogAnalytics"
  target_resource_id         = "${azurerm_automation_account.automation_account.id}"
  log_analytics_workspace_id = var.automation_workspace_id

  log {
    category = "JobLogs"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "JobStreams"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "DscNodeStatus"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  metric {
    category = "AllMetrics"
    enabled = false

    retention_policy {
      enabled = false
    }
  }

  lifecycle {
     ignore_changes = all
  }
}

# Send metrics to Log Analytics
resource "azurerm_monitor_diagnostic_setting" "aa_diags_metrics" {
  count                      = "${var.enable_update_management ? 1 : 0}"
  name                       = "MetricsToLogAnalytics"
  target_resource_id         = "${azurerm_automation_account.automation_account.id}"
  log_analytics_workspace_id =  var.automation_workspace_id

    log {
    category = "JobLogs"
    enabled  = false

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "JobStreams"
    enabled  = false

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "DscNodeStatus"
    enabled  = false

    retention_policy {
      enabled = false
    }
  }

  metric {
    category = "AllMetrics"
    enabled = true

    retention_policy {
      enabled = false
    }
  }
  
  lifecycle {
     ignore_changes = all
  }
}