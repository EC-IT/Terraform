resource "azurerm_route_table" "udr" {
  for_each = {for i, v in var.vnet_udr:  i => v}
  name                          = each.value.name
  location                      = azurerm_virtual_network.vnet.location
  resource_group_name           = azurerm_virtual_network.vnet.resource_group_name
  disable_bgp_route_propagation = false

 dynamic "route" {
    for_each = [for s in each.value.route : {
      name                       = s.name
      address_prefix             = s.address_prefix
      next_hop_type              = s.next_hop_type
      next_hop_in_ip_address     = s.next_hop_in_ip_address    
    }]
    content {
      name                       = route.value.name
      address_prefix             = route.value.address_prefix
      next_hop_type              = route.value.next_hop_type
      next_hop_in_ip_address     = "${route.value.next_hop_type == "VirtualAppliance" ? route.value.next_hop_in_ip_address : null}"
      
    }
 }
  tags = var.aztags
}

output "udr_id" {
  value = tomap({
    for inst in azurerm_route_table.udr : inst.name => inst.id
  })
}
