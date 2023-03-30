output "webapp_url" {
    value = azurerm_windows_web_app.webapplication.default_hostname
}

output "webapp_id" {
    value = azurerm_windows_web_app.webapplication.id
}

output "webapp_ips" {
    value = azurerm_windows_web_app.webapplication.outbound_ip_addresses
}