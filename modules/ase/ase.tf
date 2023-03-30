
resource "azurerm_app_service_environment_v3" "ase" {
  name                         = var.ase_name
  resource_group_name          = var.ase_rg
  subnet_id                    = var.ase_subnet_id
  internal_load_balancing_mode = var.ase_load_balancing_mode
/*
 # BUG : https://githubmemory.com/repo/terraform-providers/terraform-provider-azurerm/issues/12625
  cluster_setting {
    name  = "DisableTls1.0"
    value = "1"
  }

  cluster_setting {
    name  = "DisableTls1.1"
    value = "1"
  }
*/
  cluster_setting {
    name  = "InternalEncryption"
    value = "true"
  }

  cluster_setting {
    name  = "FrontEndSSLCipherSuiteOrder"
    value = "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"
  }

  tags = var.aztags
}

output "ase_id" {
  value = azurerm_app_service_environment_v3.ase.id
}

resource "azurerm_app_service_plan" "appwin" {
  for_each            = {for p in var.app_plans : p.name => p }
  name                = each.key
  location            = azurerm_app_service_environment_v3.ase.location
  resource_group_name = var.ase_rg
  app_service_environment_id = azurerm_app_service_environment_v3.ase.id

  kind                = each.value.kind

  sku {
    tier = each.value.tier
    size = each.value.size
    capacity = each.value.capacity
  }
  tags = each.value.tags
}

output "plan_id" {
  value = tomap({
    for plan in azurerm_app_service_plan.appwin : plan.name => plan.id
  })
}
