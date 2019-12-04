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
  type        = string
}
```

## aks_node_rg

```sh
variable "aks_node_rg" {
  description = "(Optional) The name of the Resource Group where the the Kubernetes Nodes should exist."
  type        = string
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
    type                = string
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
    type                = "VirtualMachineScaleSets"
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
    type                = "VirtualMachineScaleSets"
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
    type                = "VirtualMachineScaleSets"
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
    oms_agent_enabled = false # Enable Container Monitoring
    http_application_routing_enabled = false # Disable HTTP Application Routing
    kube_dashboard_enabled = false # Disable Kubernetes Dashboard
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

## diagnostics_log_category

```sh
variable "diagnostics_logs_map" {
  description = "(Optional) Send the logs generated by AKS master node to diagnostics"
  default = {
    log = [
      #["Category name",  "Diagnostics Enabled", "Retention Enabled", Retention period]
      ["kube-apiserver", true, true, 30],
      ["kube-controller-manager", true, true, 30],
      ["kube-scheduler", true, true, 30],
      ["kube-audit", true, true, 30],
      ["cluster-autoscaler", true, true, 30]
    ]
    metric = [
      ["AllMetrics", true, true, 30],
    ]
  }
}
```

## diagnostics_map

```sh
variable "diagnostics_map" {
  description = "(Optional) Storage Account and Event Hub data for the AKS diagnostics"
  default = {
    log_analytics_workspace_id = null
    diags_sa = null
    eh_id    = ""
    eh_name  = null
  }
}
```

# Output

| Name            | Description                                                            |
| --------------- | ---------------------------------------------------------------------- |
| kube_config     | kube_config block that comprised crendetials                           |
| kube_config_raw | Raw Kubernetes config to be used by kubectl and other compatible tools |
| ssh_key         | The private key used by worker nodes                                   |

NOTE: kube_config credentials can be used with the Kubernetes Provider like so:

```sh
provider "kubernetes" {
  host                   = "${azurerm_kubernetes_cluster.main.kube_config.0.host}"
  username               = "${azurerm_kubernetes_cluster.main.kube_config.0.username}"
  password               = "${azurerm_kubernetes_cluster.main.kube_config.0.password}"
  client_certificate     = "${base64decode(azurerm_kubernetes_cluster.main.kube_config.0.client_certificate)}"
  client_key             = "${base64decode(azurerm_kubernetes_cluster.main.kube_config.0.client_key)}"
  cluster_ca_certificate = "${base64decode(azurerm_kubernetes_cluster.main.kube_config.0.cluster_ca_certificate)}"
}
```

# Contribute

Pull requests are welcome to evolve this module and integrate new features.
