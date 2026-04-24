# data_connectors.tf — Azure Sentinel Data Source Connectors

# ── Azure Active Directory ────────────────────────────────────
resource "azurerm_sentinel_data_connector_azure_active_directory" "aad" {
  name                       = "connector-azure-ad"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.sentinel.workspace_id
}

# ── Microsoft Defender for Cloud ─────────────────────────────
resource "azurerm_sentinel_data_connector_microsoft_defender_advanced_threat_protection" "defender" {
  name                       = "connector-defender-atp"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.sentinel.workspace_id
}

# ── Azure Activity Logs ───────────────────────────────────────
resource "azurerm_sentinel_data_connector_azure_active_directory" "activity" {
  name                       = "connector-azure-activity"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.sentinel.workspace_id
}

# ── Threat Intelligence ───────────────────────────────────────
resource "azurerm_sentinel_data_connector_threat_intelligence" "ti" {
  name                       = "connector-threat-intel"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.sentinel.workspace_id
}
