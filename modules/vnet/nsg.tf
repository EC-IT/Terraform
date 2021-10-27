
resource "azurerm_network_security_group" "nsg" {
  for_each = {for i, v in var.vnet_nsg:  i => v}
  name                = each.value.name
  location            = azurerm_virtual_network.vnet.location
  resource_group_name = azurerm_virtual_network.vnet.resource_group_name

 dynamic "security_rule" {
    for_each = [for s in each.value.security_rule : {
      name                       = s.name
      priority                   = s.priority
      direction                  = s.direction
      access                     = s.access
      protocol                   = s.protocol
      #source_port_ranges         = split(",", replace(s.src_port, "*", "0-65535"))
      #source_port_ranges         = ["0-65535"]
      source_port_ranges         = []
      #destination_port_ranges    = split(",", replace(s.dest_port, "*", "0-65535"))
      destination_port_ranges    = s.dest_port
      source_address_prefixes      = s.src_ip
      destination_address_prefixes = s.dest_ip
      description                = s.description
    }]
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      description                 = security_rule.value.description
      
      source_port_ranges         = security_rule.value.source_port_ranges
      source_port_range          = "${length(security_rule.value.source_port_ranges) != 0 ? null : "*" }"
      destination_port_ranges    = security_rule.value.destination_port_ranges
      destination_port_range     = "${length(security_rule.value.destination_port_ranges) != 0 ? null : "*" }"
      source_address_prefixes    = security_rule.value.source_address_prefixes
      source_address_prefix      = "${length(security_rule.value.source_address_prefixes) != 0 ? null : "*" }"
      destination_address_prefixes = security_rule.value.destination_address_prefixes
      destination_address_prefix  = "${length(security_rule.value.destination_address_prefixes) != 0 ? null : "*" }"
    }
  }

  tags = var.aztags
}

output "nsg_id" {
  value = tomap({
    for inst in azurerm_network_security_group.nsg : inst.name => inst.id
  })
}
