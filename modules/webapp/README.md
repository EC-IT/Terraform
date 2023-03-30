## Example

```terraform
module "webapp-myapp-ppd" {
  source                             = "./modules/webapp"
  app_service_name                   = "myapp-ppd-web"
  app_service_resource_group         = "myapp-NPE-rg"
  app_service_plan_name              = "asenp0001-ppd-windows-plan001"
  app_service_plan_rg_name           = "IT-NPE-rg"
  app_service_domain                 = ["myapp-pre.myengie.com","myapp-pre.gdfsuez.net"]
  app_service_dotnet_version         = "v6.0"
  app_service_always_on              = false
  app_service_aspnetcore_environment = "Preproduction"
  app_service_tag_application        = "myapp"
  app_service_tag_environment        = "PRE-PROD"
  app_service_enable_backend         = true
  app_service_backup_enable          = true
  app_service_backup_sa_name         = "backupnpesa"
  app_service_backup_sa_rg           = "Backup-NPE-rg"
  app_service_enable_manage_identity = true
  app_service_enable_logs_blob       = true
  app_service_logs_sa_name           = "lognpesa"
  app_service_logs_sa_rg             = "IT-NPE-rg"
  app_service_logs_retention         = 30
}
```