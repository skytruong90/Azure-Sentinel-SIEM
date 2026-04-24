# Azure-Sentinel-SIEM

[![Azure](https://img.shields.io/badge/Azure-Sentinel-%230072C6?style=flat-square&logo=microsoftazure&logoColor=white)](https://github.com/skytruong90/Azure-Sentinel-SIEM)
[![Domain](https://img.shields.io/badge/Domain-Defense_Security-red?style=flat-square)](https://github.com/skytruong90/Azure-Sentinel-SIEM)
[![SIEM](https://img.shields.io/badge/Type-Threat_Detection_%26_Response-00C8FF?style=flat-square)](https://github.com/skytruong90/Azure-Sentinel-SIEM)
[![Cert](https://img.shields.io/badge/CISSP-Certified-A78BFA?style=flat-square)](https://github.com/skytruong90/Azure-Sentinel-SIEM)
[![Status](https://img.shields.io/badge/Status-Active-00FF88?style=flat-square)](https://github.com/skytruong90/Azure-Sentinel-SIEM)

## Project Overview

A cloud-native Security Information and Event Management (SIEM) deployment using **Microsoft Azure Sentinel**, designed to demonstrate real-time threat detection, incident response, and security monitoring capabilities applicable to defense and government cloud environments.

This project provisions a fully operational Sentinel workspace that ingests live security telemetry, visualizes global attack patterns via interactive workbooks, and triggers automated incident response playbooks — mirroring the security posture required for DoD and defense contractor environments.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                  AZURE SENTINEL SIEM ARCHITECTURE               │
│                                                                  │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────────┐  │
│  │  Data Sources │───▶│Log Analytics │───▶│ Azure Sentinel   │  │
│  │              │    │  Workspace   │    │                  │  │
│  │ • Azure AD   │    │              │    │ • Analytics Rules│  │
│  │ • VM Logs    │    │  (KQL Store) │    │ • Threat Intel   │  │
│  │ • Firewall   │    │              │    │ • Incidents      │  │
│  │ • Defender   │    └──────────────┘    │ • Workbooks      │  │
│  │ • Custom API │                        └──────────────────┘  │
│  └──────────────┘                                │              │
│                                                  ▼              │
│                                    ┌──────────────────────┐    │
│                                    │  Logic App Playbooks  │    │
│                                    │  (Automated Response) │    │
│                                    │                       │    │
│                                    │ • Auto-block IP       │    │
│                                    │ • Alert SOC team      │    │
│                                    │ • Isolate endpoint    │    │
│                                    └──────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

---

## Project Structure

```bash
Azure-Sentinel-SIEM/
├── terraform/
│   ├── main.tf               # Sentinel workspace provisioning
│   ├── variables.tf          # Input variables
│   ├── outputs.tf            # Workspace ID and key outputs
│   └── data_connectors.tf    # Data source connector config
├── analytics_rules/
│   ├── brute_force.json      # Brute force detection rule
│   ├── geo_anomaly.json      # Impossible travel / geo anomaly
│   └── privilege_escalation.json
├── playbooks/
│   └── auto_block_ip.json    # Logic App: auto-block malicious IPs
├── workbooks/
│   └── attack_map.json       # Global attack visualization workbook
├── queries/
│   ├── failed_logins.kql     # KQL: failed authentication attempts
│   ├── geo_attack_map.kql    # KQL: geolocation threat mapping
│   └── privilege_events.kql  # KQL: privilege escalation detection
├── screenshots/
│   └── attack_map.png        # Live global attack map
├── .gitignore
└── README.md
```

---

## Features

- **Real-Time Threat Detection** — Ingests live security telemetry from Azure AD, VMs, firewalls, and Microsoft Defender, triggering alerts on anomalous behavior within seconds.
- **Global Attack Visualization** — Interactive workbook maps brute-force and unauthorized access attempts to geolocation coordinates in real time.
- **Automated Incident Response** — Logic App playbooks auto-block malicious IPs, notify the SOC team, and isolate compromised endpoints without manual intervention.
- **Custom KQL Analytics Rules** — Purpose-built detection rules for brute-force attacks, impossible travel anomalies, and privilege escalation events.
- **Defense-Grade Data Connectors** — Integrates Azure AD, Microsoft Defender for Cloud, Azure Firewall, and custom REST API log sources.

---

## Detection Rules

| Rule | Trigger | Severity |
|------|---------|----------|
| Brute Force Detection | 10+ failed logins in 5 min from single IP | High |
| Impossible Travel | Login from 2 locations > 500km apart in < 1hr | High |
| Privilege Escalation | Global Admin role assigned outside business hours | Critical |
| Mass Data Exfiltration | Outbound transfer > 1GB to non-whitelisted IP | Critical |
| Geo-Anomaly Login | Authentication from sanctioned country list | Medium |

---

## KQL Queries

### Failed Login Attempts — Brute Force Detection

```kql
SecurityEvent
| where EventID == 4625
| where TimeGenerated > ago(5m)
| summarize FailedAttempts = count() by IpAddress, Account
| where FailedAttempts > 10
| extend GeoInfo = geo_info_from_ip_address(IpAddress)
| project TimeGenerated, IpAddress, Account, FailedAttempts,
          Country = GeoInfo.country, Latitude = GeoInfo.latitude,
          Longitude = GeoInfo.longitude
| order by FailedAttempts desc
```

### Global Attack Map — Geolocation Mapping

```kql
SecurityEvent
| where EventID == 4625
| where TimeGenerated > ago(24h)
| extend GeoInfo = geo_info_from_ip_address(IpAddress)
| summarize AttackCount = count() by
    Country     = tostring(GeoInfo.country),
    Latitude    = tostring(GeoInfo.latitude),
    Longitude   = tostring(GeoInfo.longitude)
| where isnotempty(Country)
| order by AttackCount desc
```

### Privilege Escalation Detection

```kql
AuditLogs
| where OperationName == "Add member to role"
| where TimeGenerated > ago(1h)
| extend TargetRole = tostring(TargetResources[0].displayName)
| where TargetRole contains "Global Administrator"
| extend InitiatedBy = tostring(InitiatedBy.user.userPrincipalName)
| project TimeGenerated, InitiatedBy, TargetRole, Result
| where hourofday(TimeGenerated) !between (8 .. 18)
```

---

## Terraform Deployment

### Provision Sentinel Workspace

```hcl
# main.tf
resource "azurerm_resource_group" "sentinel" {
  name     = "rg-sentinel-${var.environment}"
  location = var.location
}

resource "azurerm_log_analytics_workspace" "sentinel" {
  name                = "law-sentinel-${var.environment}"
  location            = azurerm_resource_group.sentinel.location
  resource_group_name = azurerm_resource_group.sentinel.name
  sku                 = "PerGB2018"
  retention_in_days   = 90
}

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "sentinel" {
  workspace_id = azurerm_log_analytics_workspace.sentinel.id
}
```

### Variables

```hcl
# variables.tf
variable "location" {
  description = "Azure region for deployment"
  type        = string
  default     = "East US"
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}
```

---

## Getting Started

### Prerequisites

- Azure subscription with **Sentinel** and **Log Analytics** enabled
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) installed and authenticated
- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5.0

### Deployment

1. Clone the repository:

```bash
git clone https://github.com/skytruong90/Azure-Sentinel-SIEM.git
cd Azure-Sentinel-SIEM/terraform
```

2. Login to Azure:

```bash
az login
```

3. Initialize and apply Terraform:

```bash
terraform init
terraform plan -var="environment=dev"
terraform apply -var="environment=dev"
```

4. Import analytics rules into Sentinel:

```bash
az sentinel alert-rule create \
  --resource-group rg-sentinel-dev \
  --workspace-name law-sentinel-dev \
  --rule-id brute-force-detection \
  --rule-file ../analytics_rules/brute_force.json
```

---

## Security Posture

| Control | Implementation |
|--------|----------------|
| Data Encryption | All Log Analytics data encrypted at rest (AES-256) |
| RBAC | Least-privilege roles scoped per analyst tier |
| Retention Policy | 90-day hot storage, 1-year cold archive |
| Audit Logging | All Sentinel actions logged to immutable audit trail |
| Network Isolation | Workspace access restricted to private endpoints |

---

## Future Enhancements

- **MITRE ATT&CK Mapping** — Align detection rules to MITRE ATT&CK framework tactics and techniques for structured threat coverage.
- **SOAR Integration** — Expand playbook automation with full Security Orchestration, Automation and Response (SOAR) workflows.
- **Threat Intelligence Feed** — Integrate Microsoft Defender Threat Intelligence and government-specific IOC feeds.
- **FedRAMP Alignment** — Adapt configuration to meet FedRAMP Moderate/High baseline controls for government cloud deployment.
- **Multi-Tenant Monitoring** — Extend Sentinel to monitor across multiple Azure tenants for enterprise defense environments.

---

## Technical Background

| Concept | Implementation |
|--------|----------------|
| SIEM Platform | Microsoft Azure Sentinel |
| Query Language | Kusto Query Language (KQL) |
| Infrastructure | Terraform on Azure |
| Incident Response | Azure Logic Apps (Playbooks) |
| Visualization | Azure Workbooks — global attack map |
| Data Sources | Azure AD, Defender, Firewall, VM Security Events |

---

<div align="center">

[![View Repository](https://img.shields.io/badge/View_Repository-%E2%86%97-00C8FF?style=for-the-badge&labelColor=050A0F)](https://github.com/skytruong90/Azure-Sentinel-SIEM)

</div>
