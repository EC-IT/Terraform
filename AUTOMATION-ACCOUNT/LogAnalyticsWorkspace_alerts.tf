locals {
    alerts = [
        {
            name = "checkCPU_95percent"
            email_subject = "alerte CPU"
            description = "Aletre CPU supérieur à 95%"
            query = "Perf | where CounterName == \"% Processor Time\" and CounterValue > 80 and ObjectName == \"Processor\" and InstanceName == \"_Total\" and TimeGenerated > ago(30m) | summarize avg(CounterValue) by Computer | where avg_CounterValue > 95"
            severity = 2
            frequency = 10
            time_window = 30
            threshold = 2
            action_group = "AdminGroup"
        },
        {
            name = "checkDisk_5percent"
            email_subject = "alerte disque"
            description = "Alerte si une VM à moins de 5% d'espace disque libre"
            query = "Perf | where ObjectName == \"LogicalDisk\" and TimeGenerated > ago(30m) and CounterName == \"% Free Space\" and InstanceName != \"_Total\" and CounterValue < 5 | distinct Computer"
            severity = 2, frequency = 10, time_window = 30, threshold = 2
            action_group = "AdminGroup"
        },
        {
            name = "checkMemory_1G"
            email_subject = "alerte RAM"
            description = "Alerte si une VM à moins de 1Go de mémoire libre"
            query = "Perf | where CounterName == \"Available Mbytes\"  and TimeGenerated > ago(30m) and CounterValue < 1000"
            severity = 2, frequency = 10, time_window = 30, threshold = 2
            action_group = "AdminGroup"
        },
        {
            name = "check_NSG_blocked"
            email_subject = "Trafic bloqué par un NSG"
            description = "Trafic entrant bloqué par un NSG"
            query = "AzureNetworkAnalytics_CL | where NSGRule_s contains \"all_inbound_deny\" or NSGRule_s contains \"all_outbound_deny\" | distinct NSGList_s, SrcPublicIPs_s, SrcIP_s, DestIP_s, DestPublicIPs_s, DestPort_d"
            severity = 2, frequency = 10, time_window = 30, threshold = 1
            action_group = "AdminGroup"
        },
        {
            name = "EventWindowsError"
            email_subject = "EventWindowsError"
            description = "Evenement de type erreur dans les journaux d'événements Windows "
            query = "Event | where EventLevel == 1 and Source !contains \"DistributedCOM\" and Source !contains \"COMRuntime\" and Source !contains \"SIDE\" and Source !contains \"PBIRS\" and EventCategory != 6 and EventCategory != 0 and EventCategory != 100  and EventID != 1002  and EventID != 18210 and EventID != 490 and EventID != 489 and EventID != 455"
            severity = 2, frequency = 10, time_window = 30, threshold = 1
            action_group = "AdminGroup"
        },
    ]
    action_group = [
        {
            name = "AdminGroup"
            email_address = "admin_team@corp.local"
            email_name = "AlertEmailAdmin"
        }
    ]
}

module "loganalytics_alert" {
    source            = "../modules/loganalytics_alert"
    alerts            = local.alerts
    action_group      = local.action_group
    location          = data.azurerm_resource_group.rg.location
    rg_name           = data.azurerm_resource_group.rg.name
    insight_id        = azurerm_log_analytics_workspace.LogAnalyticsWorkspace.id

    aztags            = local.aztags_it_preprod
}
