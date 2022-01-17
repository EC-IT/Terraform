
provider "azurerm" {
  features {}
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.76.0"
    }
    time = {
      source = "hashicorp/time"
      version = "0.7.2"
    }
  }
}
