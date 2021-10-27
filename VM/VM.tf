data "azurerm_resource_group" "rg" {
  name     = "prod-rg"
}

locals {
  vm_ips = ["192.168.10.10","192.168.10.11"]
  vm_zones = ["1","2"]
}

module "virtualmachine" {
  count               = 2
  #count               = 1
  source              = "../modules/virtualmachine"
  vm_name             = "PRODVM00${count.index+1}"
  vm_location         = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  vm_size             = "Standard_DS4_v2"
  vnet_name           = "VNet-Prod"
  vnet_rg             = "prod-rg"
  subnet_name         = "SubNet-Intranet"
  ip_address          = element(local.vm_ips, count.index)
  disks               = [1024, 1024]
  vm_zone             = element(local.vm_zones, count.index)
  licence_hybrid_benefit = false

  key_vault_name  = "accounts-KV"
  key_vault_rg    = "IT-rg"
  secret_username = "vm-admin-username"
  secret_password = "vm-admin-password"

  # TO ENABLE
  enable_backup = true
  backup_policy_name  = "Default-Policy"
  recovery_vault_name = "PROD001-RSV"
  backup_policy_rg    = "backupvault-rg"

  #TO ENABLE
  disk_encryption     = false
  keyvault_bitlocker  = "core-KV"
  keyvault_bitlocker_rg = "prod-rg"
  keyname             = "VM-DISK-RSA001"
  keyversion          = "xxxxxxxxxxxxxxxxxxxxx"
  subscription_id     = "xxxxxxxxxxxxxxxxxxxxx"

  vm_diag_enable      = true
  vm_diag_sa          = "logprdsa"
  vm_diag_sa_rg       = "prod-rg"

  tag_ec_application = "APP"
  tag_ec_environment = "PROD"
}