variable "billing_account" {
  description = "The ID of the target Google Cloud Billing Account (e.g. 015205-208793-CA04DA)."
  type        = string
}

variable "budget_amount" {
  description = "The target monthly budget amount in the specified currency."
  type        = number
}

variable "currency_code" {
  description = "The 3-letter currency code (ISO 4217) for the budget amount (e.g. USD, EUR, GBP)."
  type        = string
  default     = "USD"
}

variable "display_name" {
  description = "User-visible display name for the budget alert."
  type        = string
  default     = "Monthly Spend Budget"
}

variable "projects" {
  description = "List of GCP project resource names (e.g. ['projects/my-project-id']) to scope the budget to. If empty, the budget applies to all projects under the billing account."
  type        = list(string)
  default     = []
}

variable "services" {
  description = "List of GCP service IDs (e.g. ['services/24E6-581D-38E5']) to filter by. If empty, all services are included."
  type        = list(string)
  default     = []
}

variable "credit_types_treatment" {
  description = "Specifies how credits are treated when evaluating spend against the budget. Options: INCLUDE_ALL_CREDITS, EXCLUDE_ALL_CREDITS, INCLUDE_SPECIFIED_CREDITS."
  type        = string
  default     = "INCLUDE_ALL_CREDITS"
}

variable "threshold_rules" {
  description = "List of threshold alert rules. Defaults to alerts at 70%, 80%, 90%, 100% current spend and 100% forecasted spend."
  type = list(object({
    threshold_percent = number
    spend_basis       = optional(string, "CURRENT_SPEND")
  }))
  default = [
    { threshold_percent = 0.70, spend_basis = "CURRENT_SPEND" },
    { threshold_percent = 0.80, spend_basis = "CURRENT_SPEND" },
    { threshold_percent = 0.90, spend_basis = "CURRENT_SPEND" },
    { threshold_percent = 1.00, spend_basis = "CURRENT_SPEND" },
    { threshold_percent = 1.00, spend_basis = "FORECASTED_SPEND" }
  ]
}

variable "monitoring_notification_channels" {
  description = "Optional list of Cloud Monitoring notification channel IDs (e.g. projects/[PROJECT_ID]/notificationChannels/[CHANNEL_ID]) to receive budget alert notifications."
  type        = list(string)
  default     = []
}

variable "pubsub_topic" {
  description = "Optional Cloud Pub/Sub topic ID (e.g. projects/[PROJECT_ID]/topics/[TOPIC_NAME]) to send budget programmatic notification messages to."
  type        = string
  default     = null
}

variable "disable_default_iam_recipients" {
  description = "When set to true, disables email notifications to Billing Account Administrators and Billing Account Users."
  type        = bool
  default     = false
}
