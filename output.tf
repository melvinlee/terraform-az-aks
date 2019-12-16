output "kube_config" {
  value     = azurerm_kubernetes_cluster.aks.kube_config
  sensitive = true
}

output "kube_config_raw" {
  value     = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}

output "config" {
  value = <<CONFIGURE

Run the following commands to configure kubernetes clients:

$ terraform output kube_config_raw > ~/.kube/aksconfig
$ export KUBECONFIG=~/.kube/aksconfig

CONFIGURE

}

output "ssh_key" {
  value     = tls_private_key.key
  sensitive = true
}
