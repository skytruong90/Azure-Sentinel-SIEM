# main.tf — Azure Sentinel SIEM for Defense Security Monitoring
# Author: David Tan | github.com/skytruong90

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# ── Resource Group ────────────────────────────────────────────
resource "azurerm_resource_group" "sentinel" {
  name     = "rg-sentinel-${var.environment}"
  location = var.location

  tags = {
    Project     = "Azure-Sentinel-SIEM"
    Environment = var.environment
    ManagedBy   = "terraform"
    Owner       = "skytruong90"
  }
}

# ── Log Analytics Workspace ───────────────────────────────────
resource "azurerm_log_analytics_workspace" "sentinel" {
  name                = "law-sentinel-${var.environment}"
  location            = azurerm_resource_group.sentinel.location
  resource_group_name = azurerm_resource_group.sentinel.name
  sku                 = "PerGB2018"
  retention_in_days   = 90

  tags = {
    Project     = "Azure-Sentinel-SIEM"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# ── Azure Sentinel Onboarding ─────────────────────────────────
resource "azurerm_sentinel_log_analytics_workspace_onboarding" "sentinel" {
  workspace_id = azurerm_log_analytics_workspace.sentinel.id
}

# ── KMS / Encryption Key ──────────────────────────────────────
resource "azurerm_key_vault" "sentinel" {
  name                        = "kv-sentinel-${var.environment}"
  location                    = azurerm_resource_group.sentinel.location
  resource_group_name         = azurerm_resource_group.sentinel.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true

  tags = {
    Project     = "Azure-Sentinel-SIEM"
    Environment = var.environment
  }
}

# ── Data Sources ──────────────────────────────────────────────
data "azurerm_client_config" "current" {}
