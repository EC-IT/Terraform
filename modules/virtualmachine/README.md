## Example

```terraform

locals {
    vm = [
        {
            name = "APPVM001",
            vm_rg = "VM-RG",
            vm_size = "Standard_DS13_v2",
            ip_address = "10.100.100.123",
            zone = 1
        },
    ]
}

module "virtualmachine" {
  source              = "../modules/virtualmachine"
  for_each            = { for vm in local.vm : vm.name => vm }
  vm_name             = each.key
  vm_location         = "West Europe"
  resource_group_name = each.value.vm_rg
  vm_size             = each.value.vm_size
  vnet_name           = "VNet-Glb-Prod"
  vnet_rg             = "Prod_Core"
  subnet_name         = "SubNet-Intranet"
  ip_address          = each.value.ip_address
  disks_account_type  = "Premium_LRS"
  disks               = [1024]
  vm_zone             = each.value.zone
  vm_image_sku        = "2022-Datacenter"

  key_vault_name  = "accounts-KV"
  key_vault_rg    = "IT-rg"
  secret_username = "vm-admin-username"
  secret_password = "vm-admin-password"

  licence_hybrid_benefit = true

  enable_backup = false
  backup_policy_name  = "Default-Policy"
  recovery_vault_name = "PROD001-RSV"
  backup_policy_rg    = "backupvault-rg"

  disk_encryption     = false

  vm_diag_enable      = true
  vm_diag_sa          = "logprdsa"
  vm_diag_sa_rg       = "Backup-rg"
  
  tag_application = "APP"
  tag_environment = "PROD"
}


```