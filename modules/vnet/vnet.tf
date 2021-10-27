
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = var.vnet_location
  resource_group_name = var.vnet_rg
  address_space       = var.vnet_address_space
  dns_servers         = var.vnet_dns

  tags = var.aztags
}

resource "azurerm_subnet" "subnet" {
  for_each = {for s in var.vnet_subnet : s.name => s }
  resource_group_name  = azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  name                 = each.key
  address_prefixes     = each.value.cidr

 dynamic "delegation" {
   for_each = toset(each.value.delegation == "ase" ? ["delegation"] : [])
   content {
    name = "delegation"

    service_delegation {
      name    = "Microsoft.Web/hostingEnvironments"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
    }
  }
}

output "subnet_id" {
   value = tomap({
    for inst in azurerm_subnet.subnet : inst.name => inst.id
  })
  
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  for_each = {for s in var.vnet_subnet : s.name => s }
  subnet_id                 = azurerm_subnet.subnet[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg[index(var.vnet_nsg.*.name, each.value.nsg)].id
}

resource "azurerm_subnet_route_table_association" "udr_assoc" {
  for_each = {for s in var.vnet_subnet : s.name => s }
  subnet_id                 = azurerm_subnet.subnet[each.key].id
  route_table_id            = azurerm_route_table.udr[index(var.vnet_udr.*.name, each.value.udr)].id
}