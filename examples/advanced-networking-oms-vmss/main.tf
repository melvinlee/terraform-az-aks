resource "azurerm_resource_group" "example" {
  name     = "aks-advanced-networking-monitoring"
  location = "southeastasia"
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]

  subnet {
    name           = "subnet1"
    address_prefix = "10.0.1.0/24"
  }

  tags = {
    Env             = "Demo"
    DR              = "Essential"
    ApplicationName = "Microservices"
  }
}

# Create a Log Analytics (formally Operational Insights) Workspace.
resource "azurerm_log_analytics_workspace" "example" {
  name                = "la-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
}

# Create a Log Analytics (formally Operational Insights) Solution.
resource "azurerm_log_analytics_solution" "la_solution" {
  solution_name         = "ContainerInsights"
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name
  workspace_resource_id = azurerm_log_analytics_workspace.example.id
  workspace_name        = azurerm_log_analytics_workspace.example.name

  plan {
    product   = "OMSGallery/ContainerInsights"
    publisher = "Microsoft"
  }
}

module "aks" {
  source = "../../"

  service_principal = {
    client_id     = "00000000-0000-0000-0000-000000000000"
    client_secret = "00000000-0000-0000-0000-000000000000"
  }

  agent_pool_subnet_id = element(azurerm_virtual_network.example.subnet.*.id, 0)

  name     = "aks-example"
  aks_rg   = azurerm_resource_group.example.name
  location = azurerm_resource_group.example.location

  agent_pools = [{
    name                = "pool1"
    count               = 3
    vm_size             = "Standard_D2s_v3"
    os_type             = "Linux"
    os_disk_size_gb     = 50
    type                = "VirtualMachineScaleSets"
    max_pods            = 30
    availability_zones  = [1, 2, 3]
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 6
    }
  ]

  monitoring_log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id

  addon_profile = {
    oms_agent_enabled = true # Enable Container Monitoring
  }

  network_profile = {
    # Use azure-cni for advanced networking
    network_plugin = "azure"
    # Sets up network policy to be used with Azure CNI. Currently supported values are calico and azure." 
    network_policy     = "azure"
    service_cidr       = "10.100.0.0/16"
    dns_service_ip     = "10.100.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
    # Specifies the SKU of the Load Balancer used for this Kubernetes Cluster. Use standard for when enable agent_pools availability_zones.
    load_balancer_sku = "Standard"
  }

  # Configure AKS Diagnostic
  diagnostics_map = {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
  }

  tags = {
    Env             = "Demo"
    DR              = "Essential"
    ApplicationName = "Microservices"
  }

}

output "kube_config_raw" {
  value     = module.aks.kube_config_raw
  sensitive = true
}

output "config" {
  value = module.aks.config
}
