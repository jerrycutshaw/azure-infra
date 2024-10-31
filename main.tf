# Configure Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Create resource group
resource "azurerm_resource_group" "aks_rg" {
  name     = "aks-resource-group"
  location = "eastus"
}

# Create AKS cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "my-aks-cluster"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = "myakscluster"
  kubernetes_version  = "1.28"

  # Default system node pool (non-spot)
  default_node_pool {
    name                = "system"
    node_count          = 2
    vm_size            = "Standard_D2ps_v5"  # Updated to available VM size
    enable_auto_scaling = true
    min_count          = 2
    max_count          = 4
    
    # System pools should not use spot instances for reliability
    type = "VirtualMachineScaleSets"
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "kubenet"
    network_policy = "calico"
  }

  auto_scaler_profile {
    scale_down_delay_after_add       = "10m"
    scale_down_unneeded             = "10m"
    scale_down_unready              = "20m"
    scale_down_utilization_threshold = "0.5"
  }

  tags = {
    Environment = "Development"
  }
}

# Add spot instance node pool
resource "azurerm_kubernetes_cluster_node_pool" "spot" {
  name                  = "spot"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size              = "Standard_D4ps_v5"  # Updated to available VM size
  
  # Spot instance configuration
  priority        = "Spot"
  eviction_policy = "Delete"
  spot_max_price  = -1  # -1 means the current on-demand price
  
  # Auto-scaling configuration
  enable_auto_scaling = true
  min_count          = 0
  max_count          = 10
  
  # Node taints to ensure only workloads that tolerate spot instances run here
  node_taints = ["kubernetes.azure.com/scalesetpriority=spot:NoSchedule"]
  
  # Node labels
  node_labels = {
    "kubernetes.azure.com/scalesetpriority" = "spot"
    "workload-type"                         = "spot-tolerant"
  }

  tags = {
    Environment = "Development"
    NodeType    = "Spot"
  }
}

# Outputs
output "kube_config" {
  value     = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}

output "cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "spot_pool_name" {
  value = azurerm_kubernetes_cluster_node_pool.spot.name
}