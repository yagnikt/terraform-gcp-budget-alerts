resource "google_billing_budget" "budget" {
  billing_account = var.billing_account
  display_name    = var.display_name

  budget_filter {
    projects               = length(var.projects) > 0 ? var.projects : null
    services               = length(var.services) > 0 ? var.services : null
    credit_types_treatment = var.credit_types_treatment
  }

  amount {
    specified_amount {
      currency_code = var.currency_code
      units         = tostring(floor(var.budget_amount))
      nanos         = (var.budget_amount - floor(var.budget_amount)) * 1000000000
    }
  }

  dynamic "threshold_rules" {
    for_each = var.threshold_rules
    content {
      threshold_percent = threshold_rules.value.threshold_percent
      spend_basis       = lookup(threshold_rules.value, "spend_basis", "CURRENT_SPEND")
    }
  }

  dynamic "all_updates_rule" {
    for_each = (
      length(var.monitoring_notification_channels) > 0 ||
      var.pubsub_topic != null ||
      var.disable_default_iam_recipients == true
    ) ? [1] : []

    content {
      monitoring_notification_channels = length(var.monitoring_notification_channels) > 0 ? var.monitoring_notification_channels : null
      pubsub_topic                     = var.pubsub_topic
      disable_default_iam_recipients   = var.disable_default_iam_recipients
    }
  }
}
