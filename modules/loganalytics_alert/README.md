## Example

```terraform
locals {
    alerts = [
        {
            name = "checkDisk_5percent"
            email_subject = "alerte disque"
            description = "Alerte si une VM à moins de 5% d'espace disque libre"
            query = "Perf | where ObjectName == \"LogicalDisk\" and TimeGenerated > ago(30m) and CounterName == \"% Free Space\" and InstanceName != \"_Total\" and CounterValue < 5 | distinct Computer"
            severity = 2, frequency = 10, time_window = 30, threshold = 2
            action_group = "AdminGroup"
        },
    ]
    action_group = [
        {
            name = "AdminGroup"
            email_address = "admin@company.com"
            email_name = "AlertEmailEquipeInfra"
        }
    ]
}

module "loganalytics_alert" {
    source            = "../modules/loganalytics_alert"
    alerts            = local.alerts
    action_group      = local.action_group
    location          = data.azurerm_resource_group.itnperg.location
    rg_name           = data.azurerm_resource_group.itnperg.name
    insight_id        = azurerm_log_analytics_workspace.LogAnalyticsWorkspaceNPE.id

    aztags            = local.aztags_it_preprod
}

```