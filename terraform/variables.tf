# variables.tf

variable "location" {
  description = "Azure region for resource deployment"
  type        = string
  default     = "East US"
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "retention_days" {
  description = "Log retention period in days"
  type        = number
  default     = 90
}

variable "alert_email" {
  description = "Email address for SOC alert notifications"
  type        = string
  sensitive   = true
}
