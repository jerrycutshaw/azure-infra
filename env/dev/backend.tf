# resource "azurerm_storage_account" "state-bucket" {
#   name                     = "${var.environment}statebucketfortf"
#   resource_group_name      = azurerm_resource_group.aks_rg.name
#   location                 = azurerm_resource_group.aks_rg.location
#   account_tier             = "Standard"
#   account_replication_type = "LRS"  #originally "GRS" . . . assuming LRS means Local and cheap

#   tags = {
#     environment = "Development"
#   }
# }

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"             # Can be passed via `-backend-config=`"resource_group_name=<resource group name>"` in the `init` command.
    storage_account_name = "tfstatetfn"      # Can be passed via `-backend-config=`"storage_account_name=<storage account name>"` in the `init` command.
    container_name       = "tfstate-dev"                                      # Can be passed via `-backend-config=`"container_name=<container name>"` in the `init` command.
    key                  = "dev.terraform.tfstate"         # Can be passed via `-backend-config=`"key=<blob key name>"` in the `init` command.
  }
}
