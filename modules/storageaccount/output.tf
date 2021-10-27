output "name" {
  value = azurerm_storage_account.sa.name
}

output "private_ip_address" {
  value = azurerm_private_endpoint.sape[0].private_service_connection[0].private_ip_address
}