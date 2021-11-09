locals {
  runbooks = [
    {
      name           = "infra_lock_all_resources"
      description    = "Lock azure resources"
      runbook_type   = "PowerShell"
      file           = "AUTOMATION-ACCOUNT/PS/lock_all_resources.ps1"
      frequency      = "Month"
      interval       = 1
      time           = "06:00"
      week_days      = []
      month_days     = ["1"]
    }
  ]
}

resource "azurerm_log_analytics_workspace" "LogAnalyticsWorkspace" {
  name                = "LogAnalyticsWorkspace"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  #sku                 = "Standalone"
  sku                 = "pergb2018"
  retention_in_days   = 31
  daily_quota_gb      = 4

  tags                = {}
}

module "Automation" {
    source            = "../modules/automation_account"
    automation_name   = "Automation"
    automation_location = data.azurerm_resource_group.rg.location
    automation_rg     = data.azurerm_resource_group.rg.name
    automation_workspace_id = azurerm_log_analytics_workspace.LogAnalyticsWorkspace.id
    runbooks = local.runbooks

  tags                = {}
}
