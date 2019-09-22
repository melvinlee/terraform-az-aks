// Creates the diagnostics settings for the virtual network object
resource "azurerm_monitor_diagnostic_setting" "aks_diag" {

  name                           = "${azurerm_kubernetes_cluster.aks.name}-diag"
  target_resource_id             = azurerm_kubernetes_cluster.aks.id
  eventhub_name                  = var.diagnostics_map.eh_name
  eventhub_authorization_rule_id = length(var.diagnostics_map.eh_id) > 1 ? "${var.diagnostics_map.eh_id}/authorizationrules/RootManageSharedAccessKey" : null
  log_analytics_workspace_id     = var.log_analytics_workspace
  storage_account_id             = var.diagnostics_map.diags_sa

  dynamic "log" {
    for_each = toset(var.diagnostics_log_category)
    content {
      category = log.key
      retention_policy {
        days    = var.opslogs_retention_period
        enabled = true
      }
    }
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      days    = var.opslogs_retention_period
      enabled = true
    }
  }
}
