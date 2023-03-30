## Example

```terraform
locals {
  vnet_subnet = [
    {
      name              = "SubNet-Intranet-NPE"
      cidr              = ["10.100.100.0/26"]
      nsg               = "nsg_front_npe"
      udr               = "UDR-H2C"
      delegation        = ""
    },
]
  vnet_nsgs            = [ 

      {name ="nsg_aks_npe", 
      security_rule = [ 
      
    { name = "all_inbound_deny", priority = "4000", direction = "Inbound", access = "Deny", protocol = "*", dest_port = [], src_port = [], src_ip = [], dest_ip = [], description = "" },
    { name = "all_outbound_deny", priority = "4000", direction = "Outbound", access = "Deny", protocol = "*", dest_port = [], src_port = [], src_ip = [], dest_ip = [], description = "" },
    { name = "global_icmp_allow", priority = "105", direction = "Inbound", access = "Allow", protocol = "ICMP", dest_port = [], src_port = [], src_ip = [  "172.16.0.0/12",  "10.0.0.0/8"], dest_ip = ["10.168.13.0/24"], description = "" },
    { name = "global_http_allow", priority = "110", direction = "Inbound", access = "Allow", protocol = "TCP", dest_port = [  "80",  "443"], src_port = [], src_ip = [  "172.16.0.0/12",  "10.0.0.0/8"], dest_ip = ["10.168.13.0/24"], description = "" },
   
              ] },
  ]
    
  gateway = "10.10.10.254"
  azurefirewall_gateway = "10.20.20.254"
 
  vnet_udrs            = [ 
      {name ="UDR-H2C", 
      route = [ 
        { name = "H2C_10.0.0.0", address_prefix = "10.0.0.0/8", next_hop_type = "VirtualAppliance", next_hop_in_ip_address = local.gateway },
        { name = "H2C_172.16.0.0", address_prefix = "172.16.0.0/12", next_hop_type = "VirtualAppliance", next_hop_in_ip_address = local.gateway },
        { name = "Internet_par_AzureFirewall", address_prefix = "0.0.0.0/0", next_hop_type = "VirtualAppliance", next_hop_in_ip_address = local.azurefirewall_gateway }
        ] },

        ]
}


module "vnet" {
  source              = "../modules/vnet"
  vnet_name             = "VNet-Glb-NPE"
  vnet_location         = data.azurerm_resource_group.itnperg.location
  vnet_rg               = data.azurerm_resource_group.itnperg.name
  vnet_address_space    = ["10.100.100.0/24"]
  vnet_dns              = ["168.63.129.16","1.1.1.2"]
 
  vnet_nsg              = local.vnet_nsgs
  vnet_udr              = local.vnet_udrs
  vnet_subnet           = local.vnet_subnet

  vnet_nsg_logs_config         = local.vnet_nsg_logs_config
  vnet_nsg_logs_enable         = local.vnet_nsg_logs_enable
  
  # DISABLE UDR LINK
  link_udr = false

  aztags = {
    APPLICATION = "IT"
    ENVIRONMENT = "PRE-PROD"
  }

}

```