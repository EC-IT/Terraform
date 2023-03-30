```terraform
module "ASENP0001" {
  source              = "../modules/ase"
  ase_name            = "ASENP0001"
  ase_rg              = data.azurerm_resource_group.itnperg.name
  ase_subnet_id       = module.vnet.subnet_id["SubNet-ASE-NPE"]
  app_plans           = local.ase_app_plans

  aztags = {
    EC_APPLICATION = "IT"
    EC_ENVIRONMENT = "PRE-PROD"
  }

  depends_on = [module.vnet]
}

```