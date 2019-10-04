// Creates the diagnostics settings for the virtual network object
resource "azurerm_monitor_diagnostic_setting" "aks_diag" {

  name                           = "${azurerm_kubernetes_cluster.aks.name}-diag"
  target_resource_id             = azurerm_kubernetes_cluster.aks.id
  eventhub_name                  = var.diagnostics_map.eh_name
  eventhub_authorization_rule_id = length(var.diagnostics_map.eh_id) > 1 ? "${var.diagnostics_map.eh_id}/authorizationrules/RootManageSharedAccessKey" : null
  log_analytics_workspace_id     = var.log_analytics_workspace
  storage_account_id             = var.diagnostics_map.diags_sa

  dynamic "log" {
    for_each = var.diagnostics_logs_map.log
    content {
      category = log.value[0]
      enabled  = log.value[1]
      retention_policy {
        enabled = log.value[2]
        days    = log.value[3]
      }
    }
  }

  dynamic "metric" {
    for_each = var.diagnostics_logs_map.metric
    content {
      category = metric.value[0]
      enabled  = metric.value[1]
      retention_policy {
        enabled = metric.value[2]
        days    = metric.value[3]
      }
    }
  }
}
