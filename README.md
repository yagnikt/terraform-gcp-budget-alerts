# Google Cloud Budget Alerts (`terraform-gcp-budget-alerts`)

A lightweight Terraform module to set up automated Google Cloud Billing budget alerts with sensible default thresholds at **70%**, **80%**, **90%**, and **100%** spend.

---

## Quick Start

Add this module to your Terraform configuration:

```hcl
module "budget_alerts" {
  source = "git::https://github.com/cloud-gtm/fde-security-aigis.git//terraform-gcp-budget-alerts?ref=main"

  billing_account = "015205-208793-CA04DA" # Your Billing Account ID
  budget_amount   = 2000                   # Monthly limit in USD
  display_name    = "Argolis Monthly Budget ($2000 USD)"
}
```

By default, this sends alert emails to all **Billing Account Administrators & Users** at:
- **70%** actual spend ($1,400)
- **80%** actual spend ($1,600)
- **90%** actual spend ($1,800)
- **100%** actual spend ($2,000)
- **100%** forecasted spend (projected to exceed $2,000 before month end)

---

## Examples

### 1. Account-Wide Budget (Default)
Applies across all projects under the billing account:

```hcl
module "account_budget" {
  source = "git::https://github.com/cloud-gtm/fde-security-aigis.git//terraform-gcp-budget-alerts?ref=main"

  billing_account = "015205-208793-CA04DA"
  budget_amount   = 2000
}
```

### 2. Scope to Specific Project(s)
Limit the budget alert to one or more specific Google Cloud projects:

```hcl
module "project_budget" {
  source = "git::https://github.com/cloud-gtm/fde-security-aigis.git//terraform-gcp-budget-alerts?ref=main"

  billing_account = "015205-208793-CA04DA"
  budget_amount   = 500
  display_name    = "App Production Budget"

  projects = [
    "projects/my-project-id"
  ]
}
```

---

## Terraform Reference

### Inputs

| Name | Description | Type | Default | Required |
| :--- | :--- | :--- | :--- | :---: |
| `billing_account` | Target Google Cloud Billing Account ID | `string` | n/a | **yes** |
| `budget_amount` | Monthly spending limit | `number` | n/a | **yes** |
| `currency_code` | 3-letter currency code | `string` | `"USD"` | no |
| `display_name` | Budget name shown in Cloud Console | `string` | `"Monthly Spend Budget"` | no |
| `projects` | List of project resource names (`projects/PROJECT_ID`). If empty, applies to all projects. | `list(string)` | `[]` | no |
| `threshold_rules` | Custom threshold list (overrides default 70/80/90/100% tiers) | `list(object)` | `[0.70, 0.80, 0.90, 1.00 actual, 1.00 forecast]` | no |

### Outputs

| Name | Description |
| :--- | :--- |
| `budget_id` | Fully qualified budget identifier |
| `budget_name` | Resource name of the created budget |

---

## Manual Setup via Google Cloud Console

If you want to set up budget alerts directly in the Google Cloud web UI without Terraform:

1. **Open Budgets:** Go to **Google Cloud Console > Billing > Budgets & alerts** and click **+ Create budget**.
2. **Scope:** Name your budget, set Time range to **Monthly**, and leave **All projects & services** selected.
3. **Amount:** Choose **Specified amount** and enter your monthly limit (e.g., `2000`).
4. **Set Alert Rules:** Add threshold rules for:
   - `70%` — Actual spend
   - `80%` — Actual spend
   - `90%` — Actual spend
   - `100%` — Actual spend
   - `100%` — Forecasted spend
5. **Notifications:** Ensure **Email alerts to billing admins and users** is checked and click **Finish**.
