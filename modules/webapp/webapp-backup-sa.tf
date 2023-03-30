### STORAGE ACCOUNT to BACKUP APP ###
data "azurerm_storage_account" "backupsa" {
  count               = var.app_service_backup_enable ? 1 : 0
  name                = var.app_service_backup_sa_name
  resource_group_name = var.app_service_backup_sa_rg
}

resource "azurerm_storage_container" "containerbackup" {
  count                 = var.app_service_backup_enable ? 1 : 0
  name                  = "${var.app_service_name}-backup"
  storage_account_name  = var.app_service_backup_sa_name
  container_access_type = "private"
}

data "azurerm_storage_account_blob_container_sas" "urlbackup" {
  count             = var.app_service_backup_enable ? 1 : 0
  connection_string = data.azurerm_storage_account.backupsa[0].primary_connection_string
  container_name    = azurerm_storage_container.containerbackup[0].name
  https_only        = true

  start  = substr(time_offset.today.rfc3339, 0, 10)
  expiry = substr(time_offset.endday.rfc3339, 0, 10)

  permissions {
    read   = true
    add    = true
    create = true
    write  = true
    delete = true
    list   = true
  }

  content_disposition = "inline"
  content_encoding    = "deflate"
  content_language    = "en-US"
  content_type        = "application/json"
}

resource "time_offset" "today" {
  offset_days = 0
}
resource "time_offset" "endday" {
  offset_days = 365
}
