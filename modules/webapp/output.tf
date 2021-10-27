output "webapp_url" {
    value = azurerm_app_service.appservice.default_site_hostname
}

output "webapp_ips" {
    value = azurerm_app_service.appservice.outbound_ip_addresses
}