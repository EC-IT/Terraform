data "http" "deployip" {
  url = "https://ipv4.icanhazip.com"
}

resource "azurerm_storage_account" "sa" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.storage_account_location
  account_tier             = var.sa_account_tier
  account_replication_type = var.sa_replication_type
  account_kind             = var.sa_account_kind

  tags = var.aztags
  /*
  tags = {
    EC_APPLICATION = var.tag_ec_application
    EC_ENVIRONMENT = var.tag_ec_environment
  }
*/
  /*
  network_rules {
    default_action             = "Deny"
    ip_rules                   = "${concat(var.ip_rules, [chomp(data.http.deployip.body)])}"
    bypass = ["AzureServices"]
  }*/
}

resource "azurerm_storage_account_network_rules" "sanetworkrules" {
  count                = var.enable_network_rules ? 1 : 0
  resource_group_name  = azurerm_storage_account.sa.resource_group_name
  storage_account_name = azurerm_storage_account.sa.name

  default_action             = "Deny"
  #ip_rules                   = var.ip_rules
  ip_rules                   = "${concat(var.ip_rules, [chomp(data.http.deployip.body)])}"
  #virtual_network_subnet_ids = [azurerm_subnet.test.id]
  bypass                     = ["AzureServices"]

  depends_on = [azurerm_storage_account.sa]
}

data "azurerm_virtual_network" "pevnet" {
  name                = var.pe_vnet_name
  resource_group_name = var.pe_vnet_rg
}

data "azurerm_subnet" "pesubnet" {
  name                 = var.pe_subnet_name
  virtual_network_name = data.azurerm_virtual_network.pevnet.name
  resource_group_name  = data.azurerm_virtual_network.pevnet.resource_group_name
}

resource "azurerm_private_endpoint" "sape" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = "${azurerm_storage_account.sa.name}-pe"
  location            = azurerm_storage_account.sa.location
  resource_group_name = azurerm_storage_account.sa.resource_group_name
  subnet_id           = data.azurerm_subnet.pesubnet.id

  private_service_connection {
    name                           = "${azurerm_storage_account.sa.name}-psc"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.sa.id
    #subresource_names              = ["blob"]
    subresource_names              = [var.pe_subresource]
  }

}

resource "azurerm_private_dns_a_record" "dnsrecord" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = azurerm_storage_account.sa.name
  zone_name           = var.pe_dnz_zone_name
  resource_group_name = var.pe_dnz_zone_rg
  ttl                 = 300
  records             = [azurerm_private_endpoint.sape[0].private_service_connection[0].private_ip_address]
}