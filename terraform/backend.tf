terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "poketfstate29324"
    container_name       = "tfstate"
    key                  = "pokedelivery/terraform.tfstate"
  }
}
