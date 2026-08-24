module "billing_budget" {
  source = "../../"

  billing_account = "015205-208793-CA04DA"
  budget_amount   = 2000
  currency_code   = "USD"
  display_name    = "Monthly Spend Budget ($2000 USD)"

  # By default, sets alerts at 70%, 80%, 90%, 100% current spend,
  # and 100% forecasted spend across all projects in the billing account.
}
