resource "azurerm_app_service" "appservice" {
  name                = var.app_service_name
  location            = var.app_service_location
  resource_group_name = var.app_service_resource_group
  app_service_plan_id = var.app_service_plan_id
  https_only = true

  site_config {
    dotnet_framework_version = var.app_service_dotnet_version
    http2_enabled = true
    ftps_state = "Disabled"
    websockets_enabled = true
    min_tls_version = 1.2
    always_on = var.app_service_always_on
  }

  app_settings = {
    "WEBSITE_TIME_ZONE" = "Romance Standard Time"
    "WEBSITE_HTTPLOGGING_RETENTION_DAYS" = 30
    "ASPNETCORE_ENVIRONMENT" = var.app_service_aspnetcore_environment
  }


}
