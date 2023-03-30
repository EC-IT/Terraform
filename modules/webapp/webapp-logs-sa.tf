
### SOTRAGE ACCOUNT to LOGS APP ###
data "azurerm_storage_account" "logssa" {
  count               = var.app_service_enable_logs_blob ? 1 : 0
  name                = var.app_service_logs_sa_name
  resource_group_name = var.app_service_logs_sa_rg
}

### DIAG SETTINGS EXPORT  LOGS ###

resource "azurerm_monitor_diagnostic_setting" "applogs" {
  count                 = var.app_service_enable_logs_blob ? 1 : 0
  name               = "${var.app_service_name}-logs"
  target_resource_id = azurerm_windows_web_app.webapplication.id
  storage_account_id = data.azurerm_storage_account.logssa[0].id

  log {
    category = "AppServiceHTTPLogs"
    enabled  = true

    retention_policy {
      enabled = true
      days    = var.app_service_logs_retention
    }
  }

  log {
    category = "AppServiceAuditLogs"
    enabled  = true

    retention_policy {
      enabled = true
      days    = var.app_service_logs_retention
    }
  }

  log {
    category = "AppServiceAntivirusScanAuditLogs"
    enabled  = true

    retention_policy {
      enabled = true
      days    = var.app_service_logs_retention
    }
  }

 lifecycle {
    ignore_changes = [
      log,
      metric,
    ]
  }
}