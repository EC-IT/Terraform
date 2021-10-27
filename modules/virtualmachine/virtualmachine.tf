data "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = var.vnet_rg
}

data "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name
}

data "azurerm_key_vault" "kv" {
  name                = var.key_vault_name
  resource_group_name = var.key_vault_rg
}

data "azurerm_key_vault_secret" "username" {
  name         = var.secret_username
  key_vault_id = data.azurerm_key_vault.kv.id
}

data "azurerm_key_vault_secret" "password" {
  name         = var.secret_password
  key_vault_id = data.azurerm_key_vault.kv.id
}

data "azurerm_backup_policy_vm" "backup_policy" {
  name                = var.backup_policy_name
  recovery_vault_name = var.recovery_vault_name
  resource_group_name = var.backup_policy_rg
}

data "azurerm_log_analytics_workspace" "LogAnalyticsWorkspace" {
  name                = var.loganalytics_workspace
  resource_group_name = var.loganalytics_workspace_rg
}

resource "azurerm_network_interface" "nic" {
  name                          = "${var.vm_name}tf"
  location                      = var.vm_location
  resource_group_name           = var.resource_group_name
  enable_accelerated_networking = var.vm_accelerated_networking

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.ip_address
  }
}

resource "azurerm_windows_virtual_machine" "vm" {
  name                = var.vm_name
  resource_group_name = var.resource_group_name
  location            = var.vm_location
  size                = var.vm_size
  priority            = var.vm_priority
  eviction_policy     = var.vm_priority == "Spot" ? "Deallocate" : null
  zone                     = var.vm_zone
  patch_mode               = "Manual"
  enable_automatic_updates = false
   admin_username      = data.azurerm_key_vault_secret.username.value
   admin_password      = data.azurerm_key_vault_secret.password.value
  #admin_username = var.secret_username
  #admin_password = var.secret_password
  license_type         = var.licence_hybrid_benefit ? "Windows_Server" : "None"
 
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  tags = {
    EC_APPLICATION = var.tag_ec_application
    EC_ENVIRONMENT = var.tag_ec_environment
  }

  lifecycle {
    prevent_destroy = true
  }

  boot_diagnostics {
  }

}

resource "azurerm_backup_protected_vm" "backup" {
  count               = var.enable_backup ? 1 : 0
  resource_group_name = var.backup_policy_rg
  recovery_vault_name = data.azurerm_backup_policy_vm.backup_policy.recovery_vault_name
  source_vm_id        = azurerm_windows_virtual_machine.vm.id
  backup_policy_id    = data.azurerm_backup_policy_vm.backup_policy.id


  #depends_on   = [azurerm_windows_virtual_machine.vm]
}

resource "azurerm_virtual_machine_extension" "mmaagent" {
  name                       = "mmaagent"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm.id
  publisher                  = "Microsoft.EnterpriseCloud.Monitoring"
  type                       = "MicrosoftMonitoringAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = "true"
  settings                   = <<SETTINGS
    {
      "workspaceId": "${data.azurerm_log_analytics_workspace.LogAnalyticsWorkspace.workspace_id}"
    }
SETTINGS
  protected_settings         = <<PROTECTED_SETTINGS
   {
      "workspaceKey": "${data.azurerm_log_analytics_workspace.LogAnalyticsWorkspace.primary_shared_key}"
   }
PROTECTED_SETTINGS
}

resource "azurerm_managed_disk" "datadisk" {
  #count                = var.disks_quantity
  count                = length(var.disks)
  name                 = "${azurerm_windows_virtual_machine.vm.name}-disk${count.index}"
  location             = azurerm_windows_virtual_machine.vm.location
  resource_group_name  = azurerm_windows_virtual_machine.vm.resource_group_name
  #storage_account_type = "Premium_LRS"
  storage_account_type = var.disks_account_type
  create_option        = "Empty"
  disk_size_gb         = element(var.disks, count.index)
  zones                = [azurerm_windows_virtual_machine.vm.zone]

  tags = {
    EC_APPLICATION = var.tag_ec_application
    EC_ENVIRONMENT = var.tag_ec_environment
  }

  depends_on = [azurerm_windows_virtual_machine.vm]
}

resource "azurerm_virtual_machine_data_disk_attachment" "datadiskattach" {
  count           = length(var.disks)
  managed_disk_id = element(azurerm_managed_disk.datadisk.*.id, count.index)
  virtual_machine_id = azurerm_windows_virtual_machine.vm.id
  lun                = count.index
  caching            = "ReadOnly"

  depends_on = [azurerm_windows_virtual_machine.vm]
}

data "azurerm_storage_account" "diagsa" {
  count               = var.vm_diag_enable ? 1 : 0
  name                = var.vm_diag_sa
  resource_group_name = var.vm_diag_sa_rg
}

 # TODO : NE FAIT RIEN
resource "azurerm_monitor_diagnostic_setting" "vmdiag" {
  count               = var.vm_diag_enable ? 1 : 0
  name               = "VMDiagnostics"
  target_resource_id = azurerm_windows_virtual_machine.vm.id
  storage_account_id = data.azurerm_storage_account.diagsa[0].id
/*
  log {
    category = "AuditEvent"
    enabled  = true

    retention_policy {
      enabled = true
      days    = "30"
    }
  }
*/
  metric {
  category = "AllMetrics"
  enabled = true

    retention_policy {
      enabled = true
      days    = "30"
      }
    }
}

resource "azurerm_virtual_machine_extension" "disk-encryption" {
  count                = var.disk_encryption ? 1 : 0
  name                 = "DiskEncryption"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm.id
  publisher            = "Microsoft.Azure.Security"
  type                 = "AzureDiskEncryption"
  type_handler_version = "2.2"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
{
  "EncryptionOperation": "EnableEncryption",
  "KeyVaultURL": "https://${var.keyvault_bitlocker}.vault.azure.net",
  "KeyVaultResourceId": "/subscriptions/${var.subscription_id}/resourceGroups/${var.keyvault_bitlocker_rg}/providers/Microsoft.KeyVault/vaults/${var.keyvault_bitlocker}",
  "KeyEncryptionKeyURL": "https://${var.keyvault_bitlocker}.vault.azure.net/keys/${var.keyname}/${var.keyversion}",
  "KekVaultResourceId": "/subscriptions/${var.subscription_id}/resourceGroups/${var.keyvault_bitlocker_rg}/providers/Microsoft.KeyVault/vaults/${var.keyvault_bitlocker}",
  "KeyEncryptionAlgorithm": "RSA-OAEP",
  "VolumeType": "All"
}
SETTINGS
}
