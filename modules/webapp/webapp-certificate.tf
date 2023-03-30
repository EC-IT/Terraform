### APP CERTIFICATE
resource "azurerm_app_service_certificate" "appcert" {
  count               = length(var.app_service_certificate_file) == 0 ? 0 : 1
  name                = "${var.app_service_name}-cert"
  resource_group_name = var.app_service_resource_group
  location            = data.azurerm_service_plan.appplan.location
  pfx_blob            = filebase64("${var.app_service_certificate_file}")
  password            = data.azurerm_key_vault_secret.certpassword[0].value
  app_service_plan_id = data.azurerm_service_plan.appplan.id
}

data "azurerm_key_vault" "kv" {
  count               = length(var.app_service_certificate_file) == 0 ? 0 : 1
  name                = var.app_service_cert_kv_name
  resource_group_name = var.app_service_cert_kv_rg
}

data "azurerm_key_vault_secret" "certpassword" {
  count               = length(var.app_service_certificate_file) == 0 ? 0 : 1
  name                = var.app_service_cert_kv_secret
  key_vault_id        = data.azurerm_key_vault.kv[0].id
}

