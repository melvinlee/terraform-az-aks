#retrieve the version of Kubernetes supported by Azure Kubernetes Service.
data "azurerm_kubernetes_service_versions" "current" {
  location = var.location
}