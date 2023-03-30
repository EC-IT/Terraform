# **** Assigned identity ******
resource "azurerm_user_assigned_identity" "app-umi" {
  count               = var.app_service_enable_manage_identity ? 1 : 0
  resource_group_name = var.app_service_resource_group
  location            = data.azurerm_service_plan.appplan.location
  name                = "${var.app_service_name}-umi"
  tags = {
    "EC_APPLICATION"        = var.app_service_tag_application
    "EC_ENVIRONMENT"        = var.app_service_tag_environment
  }
}

