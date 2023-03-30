### APP PLAN ###
data "azurerm_service_plan" "appplan" {
  name                = var.app_service_plan_name
  resource_group_name = var.app_service_plan_rg_name
}

### APP SERVICE ###
resource "azurerm_windows_web_app" "webapplication" {
  name                             = var.app_service_name
  resource_group_name              = var.app_service_resource_group
  service_plan_id                  = data.azurerm_service_plan.appplan.id
  location                         = data.azurerm_service_plan.appplan.location
  #key_vault_reference_identity_id  = azurerm_user_assigned_identity.app-umi[0].id
  key_vault_reference_identity_id  = var.app_service_enable_manage_identity ? azurerm_user_assigned_identity.app-umi[0].id : null
  https_only                       = true


  dynamic identity { 
    for_each = var.app_service_enable_manage_identity ? [var.app_service_name] : []
    content {
      type         = "UserAssigned"
      identity_ids = [azurerm_user_assigned_identity.app-umi[0].id]
    }
  }

  site_config {
    always_on = var.app_service_always_on
    http2_enabled = true
    ftps_state = "Disabled"
    websockets_enabled = true
    minimum_tls_version = 1.2
    use_32_bit_worker = false
    health_check_path = var.app_service_health_check_enable == false ? null : var.app_service_health_check_path
    health_check_eviction_time_in_min = var.app_service_health_check_enable == false ? null : 5

    # Stack dotnet
    application_stack {
      current_stack  = "dotnet"
      dotnet_version = var.app_service_dotnet_version
    }

    # Root application
    virtual_application {
      physical_path = "site\\wwwroot"
      virtual_path  = "/"
      preload       = false
    }

    # Backend application
    dynamic virtual_application {
      for_each = var.app_service_enable_backend ? [var.app_service_name] : []
      content {
        physical_path = "site\\wwwroot_backend"
        virtual_path  = "/backend"
        preload       = false
      }
    }

    # Service application
    dynamic virtual_application {
      for_each = var.app_service_enable_services == true ? [1] : []
      content {
        physical_path = "site\\wwwroot_services"
        virtual_path  = "/services"
        preload       = false
      }
    }

    
    # BusWorker application
    dynamic virtual_application {
      for_each = var.app_service_enable_busworker == true ? [1] : []
      content {
        physical_path = "site\\jobs\\continuous\\busworker"
        virtual_path  = "/busworker"
        preload       = false
      }
    }

    # path mapping supllementaire
    dynamic virtual_application {
      for_each = var.app_service_path_mappings
      content {
        virtual_path  = virtual_application.value["virtual_path"] 
        physical_path = virtual_application.value["physical_path"] 
        preload       = virtual_application.value["preload"] 
      }
    }

  }


  app_settings = {
    "WEBSITE_TIME_ZONE" = "Romance Standard Time"
    "WEBSITE_HTTPLOGGING_RETENTION_DAYS" = 30
    "ASPNETCORE_ENVIRONMENT" = var.app_service_aspnetcore_environment
    #"WEBSITE_LOAD_CERTIFICATES" = var.app_service_website_load_certificates
  }

  # Enable backup
   dynamic backup {
      for_each = data.azurerm_storage_account_blob_container_sas.urlbackup
      content {
          name        = "${var.app_service_name}-backup"
          storage_account_url = "https://${var.app_service_backup_sa_name}.blob.core.windows.net/${var.app_service_name}-backup${data.azurerm_storage_account_blob_container_sas.urlbackup[0].sas}"
          schedule {
            frequency_interval        = 1
            frequency_unit            = "Day"
            keep_at_least_one_backup  = true
            retention_period_days     = 7
          }
      }    
    }


   tags = {
    "EC_APPLICATION"        = var.app_service_tag_application
    "EC_ENVIRONMENT"        = var.app_service_tag_environment
    "dynatrace-monitored"   = var.app_service_dynatrace_monitored
  }

  lifecycle {
    ignore_changes = [
      app_settings["WEBSITE_HTTPLOGGING_RETENTION_DAYS"],
      app_settings["WEBSITE_LOAD_CERTIFICATES"],
      app_settings["COR_PROFILER"],
      app_settings["COR_ENABLE_PROFILING"],
      app_settings["COR_PROFILER_PATH"],
      app_settings["COR_PROFILER_PATH_32"],
      app_settings["COR_PROFILER_PATH_64"],
      app_settings["CORECLR_ENABLE_PROFILING"],
      app_settings["CORECLR_PROFILER"],
      app_settings["CORECLR_PROFILER_PATH"],
      app_settings["CORECLR_PROFILER_PATH_32"],
      app_settings["CORECLR_PROFILER_PATH_64"],
      app_settings["DT_AGENTACTIVE"],
      app_settings["DT_CONNECTION_POINT"],
      app_settings["DT_LOCALTOVIRTUALHOSTNAME"],
      app_settings["DT_STORAGE"],
      app_settings["DT_TENANT"],
      app_settings["DT_TENANTTOKEN"],
      tags,
      logs,
    ]
  }

depends_on = [
    azurerm_storage_container.containerbackup,
    data.azurerm_storage_account_blob_container_sas.urlbackup,
  ]
}

### CUSTOM DNS DOMAIN ###
resource "azurerm_app_service_custom_hostname_binding" "domain" {
  count               = length(var.app_service_domain)
  hostname            = var.app_service_domain[count.index]
  app_service_name    = azurerm_windows_web_app.webapplication.name
  resource_group_name = azurerm_windows_web_app.webapplication.resource_group_name
  ssl_state           = "${length(var.app_service_certificate_file) == 0 ? null : "SniEnabled" }"
  thumbprint          =  length(var.app_service_certificate_file) == 0 ? null : azurerm_app_service_certificate.appcert[0].thumbprint
}
