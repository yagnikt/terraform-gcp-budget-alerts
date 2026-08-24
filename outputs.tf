output "budget_id" {
  description = "The fully qualified budget identifier."
  value       = google_billing_budget.budget.id
}

output "budget_name" {
  description = "The resource name of the budget in the format billingAccounts/{billing_account_id}/budgets/{budget_id}."
  value       = google_billing_budget.budget.name
}

output "threshold_rules" {
  description = "The active threshold rules configured on the budget."
  value       = var.threshold_rules
}
