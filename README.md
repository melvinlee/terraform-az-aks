# Create Azure Kubernetes Services with Advanced Networking 

Create Azure Kubernetes Services

- Advanced Networking 
- Multiple Node pools
- Diagnostics logging for master node

Reference the module to a specific version (recommended):

```sh
module "aks" {
    source = "git://github.com/melvinlee/aks-tf-module.git?ref=v0.1"
  
    aks_rg = var.aks_rg
    location = var.location
    ...
}
```

Or get the latest version

```sh
source = "git://github.com/melvinlee/aks-tf-module.git?ref=vlatest"
```

# Parameters

## aks_rg

```sh
variable "aks_rg" {
  description = "(Required) Name of the resource group where to create the aks"
  type        = string
}
```

## location 

```sh
variable "location" {
  description = "(Required) Define the region where the resource groups will be created"
  type        = string
}
```

## name

```sh
variable "name" {
  description = "(Required) The name of the Managed Kubernetes Cluster to create."
  type        = "string"
}
```

## aks_node_rg

```sh
variable "aks_node_rg" {
  description = "(Optional) The name of the Resource Group where the the Kubernetes Nodes should exist."
  type        = "string"
  default     = null
}
```

## agent_pool_subnet_id

```sh
variable "agent_pool_subnet_id" {
  description = "(Required) The ID of the Subnet where the Agents in the Pool should be provisioned."
}
```

## agent_pools

```sh
variable "agent_pools" {
  description = "(Optional) List of agent_pools profile for multiple node pools"
  type = list(object({
    name                = string
    count               = number
    vm_size             = string
    os_type             = string
    os_disk_size_gb     = number
    max_pods            = number
    availability_zones  = list(number)
    enable_auto_scaling = bool
    min_count           = number
    max_count           = number
  }))
  default = [{
    name                = "default"
    count               = 1
    vm_size             = "Standard_D2s_v3"
    os_type             = "Linux"
    os_disk_size_gb     = 50
    max_pods            = 30
    availability_zones  = [1, 2, 3]
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 3
  }]
}
```

Example

Multiple node pools with different VM type (SKU)
```sh
agent_pools = [{
    name                = "pool1"
    count               = 1
    vm_size             = "Standard_D2s_v3"
    os_type             = "Linux"
    os_disk_size_gb     = 50
    max_pods            = 30
    availability_zones  = [1, 2, 3]
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 3
  },
  {
    name                = "pool2"
    count               = 1
    vm_size             = "Standard_D4s_v3"
    os_type             = "Linux"
    os_disk_size_gb     = 30
    max_pods            = 30
    availability_zones  = [1, 2, 3]
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 3
}]
```

## linux_admin_username

```sh
variable "linux_admin_username" {
  description = "(Optional) User name for authentication to the Kubernetes linux agent virtual machines in the cluster."
  type        = "string"
  default     = "azureuser"
}
```

## kubernetes_version

```sh
variable "kubernetes_version" {
  description = "(Optional) Version of Kubernetes specified when creating the AKS managed cluster"
  default     = ""
}
```

## tags

```sh
variable "tags" {
  description = "(Required) Map of tags for the deployment"
}
```

Example

```sh
tags = {
  environment    = "development"
  creationSource = "terraform"
  department     = "ops"
  costCenter     = "8000"
}
```

## addon_profile

```sh
variable "addon_profile" {
  description = "(Optional) AddOn Profile block."
  default = {
    oms_agent = {
      enabled = true # Enable Container Monitoring
    }
    http_application_routing = {
      enabled = false # Disable HTTP Application Routing
    }
    kube_dashboard = {
      enabled = false # Disable Kubernetes Dashboard
    }
  }
}
```

## log_analytics_workspace

```sh
variable "log_analytics_workspace" {
  description = "(Optional) The ID of the Log Analytics Workspace which the OMS Agent should send data to."
  default     = null
}
```
## network_profile

```sh
variable "network_profile" {
  description = "(Optional) Sets up network profile for Advanced Networking."
  default = {
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
}
```

## service_principal

```sh
variable "service_principal" {
  description = "(Required) The Service Principal to create aks."
  type = object({
    client_id     = string
    client_secret = string
  })
}
```

Example

```sh
service_principal = {
  client_id     = "00000000-0000-0000-0000-000000000000"
  client_secret = "00000000-0000-0000-0000-000000000000"
}
```

## opslogs_retention_period

```sh
variable "opslogs_retention_period" {
  description = "(Optional) Number of days to keep operations logs inside storage account"
  default     = 60
}
```

## diagnostics_log_category

```sh
variable "diagnostics_log_category" {
  description = "(Required) Send the logs generated by AKS master node to diagnostics"
  type        = list(string)
  default = [
    "kube-apiserver",
    "kube-controller-manager",
    "kube-scheduler",
    "kube-audit",
    "cluster-autoscaler"
  ]
}
```

## diagnostics_map

```sh
variable "diagnostics_map" {
  description = "(Optional) Storage Account and Event Hub data for the AKS diagnostics"
  default = {
    diags_sa = null
    eh_id    = ""
    eh_name  = null
  }
}
```

# Output

## [kube_config](https://www.terraform.io/docs/providers/azurerm/r/kubernetes_cluster.html#kube_config)

## [kube_config_raw](https://www.terraform.io/docs/providers/azurerm/r/kubernetes_cluster.html#kube_config_raw)

## [ssh_key](https://www.terraform.io/docs/providers/tls/r/private_key.html#algorithm-1)

## config

Run the following commands to configure kubernetes clients:

$ terraform output kube_config_raw > ~/.kube/aksconfig

$ export KUBECONFIG=~/.kube/aksconfig


# Contribute

Pull requests are welcome to evolve this module and integrate new features.