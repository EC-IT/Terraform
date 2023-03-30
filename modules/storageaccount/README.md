## Example

```terraform

locals {
  sa = [
        {
        name                     = "datanpesa"
        resource_group           = "Data-NPE-rg"
        tier                     = "Standard", kind = "StorageV2", replication = "LRS", location = "West Europe"
        enable_private_endpoint  = true, pe_subresource = "blob", pe_vnet_name = "VNet-Glb-NPE", pe_vnet_rg = "IT-NPE-rg", pe_subnet_name = "SubNet-Back-NPE"
        pe_dns_enable            = false, pe_dnz_zone_name = "", pe_dnz_zone_rg = ""
        tags = {
                  APPLICATION = "DATA"
                  ENVIRONMENT = "NO-PROD"
                }
        },
  ]
    
}


module "ecappnoprodsa" {
  for_each = {for i, v in local.sa:  i => v}
  source                   = "../modules/storageaccount"
  storage_account_name     = each.value.name
  storage_account_location = each.value.location
  resource_group_name      = each.value.resource_group
  sa_account_tier          = each.value.tier
  sa_account_kind          = each.value.kind
  sa_replication_type      = each.value.replication

  enable_private_endpoint  = each.value.enable_private_endpoint
  pe_subresource           = each.value.pe_subresource
  pe_vnet_name             = each.value.pe_vnet_name
  pe_vnet_rg               = each.value.pe_vnet_rg
  pe_subnet_name           = each.value.pe_subnet_name
  enable_private_endpoint_dns = each.value.pe_dns_enable
  pe_dnz_zone_name         = each.value.pe_dnz_zone_name
  pe_dnz_zone_rg           = each.value.pe_dnz_zone_rg
  
  aztags = each.value.tags
}



```