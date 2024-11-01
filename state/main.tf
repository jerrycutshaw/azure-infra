# state/main.tf

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Random string for unique storage account name
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# State Resources
resource "azurerm_resource_group" "tfstate" {
  name     = "rg-tfstate"
  location = "eastus"
  
  tags = {
    Environment = "shared"
    Purpose     = "terraform-state"
  }
}

resource "azurerm_storage_account" "tfstate" {  # Fixed: Added resource name "tfstate"
  name                     = "tfstatetfn"
  resource_group_name      = azurerm_resource_group.tfstate.name
  location                 = azurerm_resource_group.tfstate.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  tags = {
    Environment = "shared"
    Purpose     = "terraform-state"
  }
}

# Create containers for each environment
resource "azurerm_storage_container" "environments" {
  for_each              = toset(["dev", "qa", "prod"])
  name                  = "tfstate-${each.key}"
  storage_account_name  = azurerm_storage_account.tfstate.name
}

# Output values
output "storage_account_name" {
  value = azurerm_storage_account.tfstate.name
}

output "resource_group_name" {
  value = azurerm_resource_group.tfstate.name
}