module "project_budget" {
  source = "../../"

  billing_account = "015205-208793-CA04DA"
  budget_amount   = 500
  currency_code   = "USD"
  display_name    = "Production Project Spend Budget ($500 USD)"

  # Scope alert specifically to project(s)
  projects = [
    "projects/codemender-public-preview"
  ]

  # Custom alert thresholds
  threshold_rules = [
    {
      threshold_percent = 0.50
      spend_basis       = "CURRENT_SPEND"
    },
    {
      threshold_percent = 0.70
      spend_basis       = "CURRENT_SPEND"
    },
    {
      threshold_percent = 0.80
      spend_basis       = "CURRENT_SPEND"
    },
    {
      threshold_percent = 0.90
      spend_basis       = "CURRENT_SPEND"
    },
    {
      threshold_percent = 1.00
      spend_basis       = "CURRENT_SPEND"
    },
    {
      threshold_percent = 1.00
      spend_basis       = "FORECASTED_SPEND"
    }
  ]
}
