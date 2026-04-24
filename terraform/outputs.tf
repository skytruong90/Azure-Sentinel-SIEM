# outputs.tf

output "workspace_id" {
  description = "Log Analytics Workspace ID"
  value       = azurerm_log_analytics_workspace.sentinel.id
  sensitive   = true
}

output "workspace_name" {
  description = "Log Analytics Workspace name"
  value       = azurerm_log_analytics_workspace.sentinel.name
}

output "resource_group_name" {
  description = "Resource group name"
  value       = azurerm_resource_group.sentinel.name
}

output "key_vault_uri" {
  description = "Key Vault URI for secret management"
  value       = azurerm_key_vault.sentinel.vault_uri
}
