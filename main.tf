resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.name
  dns_prefix          = var.name
  resource_group_name = var.aks_rg
  location            = var.location

  node_resource_group = var.aks_node_rg

  linux_profile {
    admin_username = var.linux_admin_username

    ssh_key {
      key_data = "${trimspace(tls_private_key.key.public_key_openssh)}"
    }
  }

  #retrieve the latest version of Kubernetes supported by Azure Kubernetes Service if version is not set
  kubernetes_version = "${var.kubernetes_version != "" ? var.kubernetes_version : data.azurerm_kubernetes_service_versions.current.latest_version}"

  dynamic "agent_pool_profile" {
    for_each = var.agent_pools
    content {
      name                = agent_pool_profile.value.name
      count               = agent_pool_profile.value.count
      vm_size             = agent_pool_profile.value.vm_size
      os_type             = agent_pool_profile.value.os_type
      os_disk_size_gb     = agent_pool_profile.value.os_disk_size_gb
      vnet_subnet_id      = var.agent_pool_subnet_id
      type                = "VirtualMachineScaleSets"
      availability_zones  = agent_pool_profile.value.availability_zones
      enable_auto_scaling = agent_pool_profile.value.enable_auto_scaling
      min_count           = agent_pool_profile.value.min_count
      max_count           = agent_pool_profile.value.max_count
      max_pods            = agent_pool_profile.value.max_pods
    }
  }

  service_principal {
    client_id     = var.service_principal.client_id
    client_secret = var.service_principal.client_secret
  }

  addon_profile {
    oms_agent {
      enabled                    = var.addon_profile.oms_agent.enabled
      log_analytics_workspace_id = var.log_analytics_workspace
    }

    http_application_routing {
      enabled = var.addon_profile.http_application_routing.enabled
    }

    kube_dashboard {
      enabled = var.addon_profile.kube_dashboard.enabled
    }
  }

  role_based_access_control {
    enabled = true
  }

  network_profile {
    network_plugin     = var.network_profile.network_plugin
    network_policy     = var.network_profile.network_policy
    service_cidr       = var.network_profile.service_cidr
    dns_service_ip     = var.network_profile.dns_service_ip
    docker_bridge_cidr = var.network_profile.docker_bridge_cidr
    load_balancer_sku  = var.network_profile.load_balancer_sku
  }

  tags = var.tags
}
