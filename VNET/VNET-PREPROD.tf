locals {
  vnet_subnet = [
    {
      name              = "SubNet-Front"
      cidr              = ["10.1.2.0/26"]
      nsg               = "nsg_front"
      udr               = "UDR-CORP"
      delegation        = ""
    },
    {
      name              = "SubNet-Back"
      cidr              = ["10.1.2.64/26"]
      nsg               = "nsg_back"
      udr               = "UDR-CORP"
      delegation        = ""
    },
    {
      name              = "SubNet-Core"
      cidr              = ["10.1.2.128/27"]
      nsg               = "nsg_core"
      udr               = "UDR-CORP"
      delegation        = ""
    },
    {
      name              = "SubNet-ASE"
      cidr              = ["10.1.2.192/26"]
      nsg               = "nsg_ase"
      udr               = "UDR-CORP-ASE"
      delegation        = "ase"
      
      }
]
}

data "azurerm_resource_group" "rg" {
  name = "preprod-rg"
}

module "vnet" {
  source              = "../modules/vnet"
  vnet_name             = "VNet-PreProd"
  vnet_location         = data.azurerm_resource_group.rg.location
  vnet_rg               = data.azurerm_resource_group.rg.name
  vnet_address_space    = ["10.1.2.0/24"]
  vnet_dns              = ["10.1.2.199","168.63.129.16"]

  vnet_nsg              = local.vnet_nsgs
  vnet_udr              = local.vnet_udrs
  vnet_subnet           = local.vnet_subnet
  
  aztags = {
    EC_APPLICATION = "IT"
    EC_ENVIRONMENT = "PRE-PROD"
  }

}
