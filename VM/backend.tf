terraform {
  backend "azurerm" {
    resource_group_name  = "rg-sa"
    storage_account_name = "sattf"
    container_name       = "tfstate"
    key                  = "terraform_.tfstate"
  }
}