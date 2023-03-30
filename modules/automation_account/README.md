## Example

```terraform
locals {
  runbooks = [
    {
      name           = "AutoStart_PreProd"
      description    = "Demarre automatiquement les VM ENVIRONMENT PRE-PROD"
      runbook_type   = "PowerShell"
      file           = "noprod/PS/AutoStart_PreProd.ps1"
      frequency      = "Day"
      interval       = 1
      time           = "07:00"
      week_days      = []
      month_days     = []
    },
  ]
}

resource "azurerm_log_analytics_workspace" "LogAnalyticsWorkspaceNPE" {
  name                = "LogAnalyticsWorkspaceNPE"
  location            = data.azurerm_resource_group.itnperg.location
  resource_group_name = data.azurerm_resource_group.itnperg.name
  sku                 = "pergb2018"
  retention_in_days   = 31
  daily_quota_gb      = 4

  tags                = {}
}

module "AutomationNPE" {
    source            = "../modules/automation_account"
    automation_name   = "AutomationNPE"
    automation_location = data.azurerm_resource_group.itnperg.location
    automation_rg     = data.azurerm_resource_group.itnperg.name
    automation_workspace_id = azurerm_log_analytics_workspace.LogAnalyticsWorkspaceNPE.id
    runbooks = local.runbooks
    enable_update_management = true

    create_job_schedule = false

    aztags            = {}
}
```