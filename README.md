# Google Cloud Billing Budget Alerts Terraform Module

A reusable, production-ready Terraform module for managing **Google Cloud Billing Budgets & Spend Alerts**. It helps engineering and FinOps teams prevent unexpected cloud overruns by establishing automated, multi-tiered alerting thresholds at **70%**, **80%**, **90%**, and **100%** of monthly budgets.

---

## Features

- **Multi-tiered Budget Thresholds:** Pre-configured with recommended alerting tiers (70%, 80%, 90%, 100% actual spend, plus 100% forecasted spend).
- **Flexible Scope:** Apply budgets across an entire Google Cloud Billing Account or scope them to specific projects or services.
- **Customizable Notifications:** Send alert emails directly to Billing Account Administrators and Users, or attach Cloud Monitoring channels (Slack, PagerDuty, Webhooks, custom email distribution lists) and Cloud Pub/Sub topics.
- **Dual Support:** Detailed instructions for deploying via **Terraform** or setting up manually in the **Google Cloud Console**.

---

## Table of Contents

- [Prerequisites & IAM Permissions](#prerequisites--iam-permissions)
- [Terraform Module Usage](#terraform-module-usage)
  - [1. Basic Account-Level Budget](#1-basic-account-level-budget)
  - [2. Project-Scoped Budget with Custom Thresholds](#2-project-scoped-budget-with-custom-thresholds)
  - [3. Budget with Cloud Monitoring Notification Channels](#3-budget-with-cloud-monitoring-notification-channels)
- [Terraform Reference](#terraform-reference)
  - [Inputs](#inputs)
  - [Outputs](#outputs)
- [How to Set Up Budget Alerts via Google Cloud Console (Manual UI Guide)](#how-to-set-up-budget-alerts-via-google-cloud-console-manual-ui-guide)

---

## Prerequisites & IAM Permissions

### Required IAM Roles
To create and manage Cloud Billing budgets, the identity (user or service account) executing Terraform must have one of the following IAM roles on the Cloud Billing Account:
- **Billing Account Costs Manager** (`roles/billing.costsManager`)
- **Billing Account Administrator** (`roles/billing.admin`)

### Cloud Billing Budget API
The Cloud Billing Budget API (`billingbudgets.googleapis.com`) must be enabled on your quota project:
```bash
gcloud services enable billingbudgets.googleapis.com --project=YOUR_PROJECT_ID
```

### Terraform Provider Setup
When using Application Default Credentials (ADC), configure `user_project_override` and `billing_project` in your Terraform Google provider:

```hcl
provider "google" {
  project               = "YOUR_PROJECT_ID"
  region                = "us-central1"
  user_project_override = true
  billing_project       = "YOUR_PROJECT_ID"
}
```

---

## Terraform Module Usage

### 1. Basic Account-Level Budget

Creates a monthly budget of **$2,000 USD** across all projects in the billing account with alerts at 70% ($1,400), 80% ($1,600), 90% ($1,800), and 100% ($2,000) actual spend, plus 100% forecasted spend:

```hcl
module "billing_budget" {
  source = "git::https://github.com/cloud-ai-fde/terraform-gcp-budget-alerts.git?ref=v1.0.0"

  billing_account = "015205-208793-CA04DA"
  budget_amount   = 2000
  currency_code   = "USD"
  display_name    = "Monthly Spend Budget ($2000 USD)"
}
```

---

### 2. Project-Scoped Budget with Custom Thresholds

Scopes a budget of **$500 USD** specifically to one project and configures custom alert tiers:

```hcl
module "project_budget" {
  source = "git::https://github.com/cloud-ai-fde/terraform-gcp-budget-alerts.git?ref=v1.0.0"

  billing_account = "015205-208793-CA04DA"
  budget_amount   = 500
  currency_code   = "USD"
  display_name    = "Core App Project Spend Budget ($500 USD)"

  projects = [
    "projects/my-app-production"
  ]

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
```

---

### 3. Budget with Cloud Monitoring Notification Channels

Sends notifications to external channels such as Slack, PagerDuty, or dedicated distribution lists in addition to Cloud Billing Admins:

```hcl
module "budget_with_slack" {
  source = "git::https://github.com/cloud-ai-fde/terraform-gcp-budget-alerts.git?ref=v1.0.0"

  billing_account = "015205-208793-CA04DA"
  budget_amount   = 3000
  currency_code   = "USD"
  display_name    = "Organization Monthly Budget with Slack Alerts"

  monitoring_notification_channels = [
    "projects/my-monitoring-project/notificationChannels/123456789012345678"
  ]
}
```

---

## Terraform Reference

### Inputs

| Name | Description | Type | Default | Required |
| :--- | :--- | :--- | :--- | :---: |
| `billing_account` | The ID of the target Google Cloud Billing Account (e.g. `015205-208793-CA04DA`). | `string` | n/a | **yes** |
| `budget_amount` | The target monthly budget amount in the specified currency. | `number` | n/a | **yes** |
| `currency_code` | 3-letter ISO 4217 currency code (e.g., `USD`, `EUR`). | `string` | `"USD"` | no |
| `display_name` | User-visible display name for the budget. | `string` | `"Monthly Spend Budget"` | no |
| `projects` | List of GCP project resource names (`projects/PROJECT_ID`). If empty, applies to all projects. | `list(string)` | `[]` | no |
| `services` | List of GCP service IDs (`services/SERVICE_ID`). If empty, applies to all services. | `list(string)` | `[]` | no |
| `credit_types_treatment` | Treatment of credits (`INCLUDE_ALL_CREDITS`, `EXCLUDE_ALL_CREDITS`, `INCLUDE_SPECIFIED_CREDITS`). | `string` | `"INCLUDE_ALL_CREDITS"` | no |
| `threshold_rules` | List of threshold alert objects with `threshold_percent` and `spend_basis`. | `list(object)` | `[0.70, 0.80, 0.90, 1.00 actual, 1.00 forecast]` | no |
| `monitoring_notification_channels` | List of Cloud Monitoring notification channel IDs to receive alert emails / webhook triggers. | `list(string)` | `[]` | no |
| `pubsub_topic` | Cloud Pub/Sub topic ID (`projects/PROJECT_ID/topics/TOPIC_NAME`) for programmatic notifications. | `string` | `null` | no |
| `disable_default_iam_recipients` | Suppress default email alerts to Billing Admins & Users. | `bool` | `false` | no |

### Outputs

| Name | Description |
| :--- | :--- |
| `budget_id` | The fully qualified budget identifier. |
| `budget_name` | The resource name of the budget (`billingAccounts/{account_id}/budgets/{budget_id}`). |
| `threshold_rules` | The active threshold rules configured on the budget. |

---

## How to Set Up Budget Alerts via Google Cloud Console (Manual UI Guide)

If you prefer to configure budget alerts manually through the Google Cloud web interface:

### Step 1: Navigate to Billing Budgets
1. Open the [Google Cloud Console](https://console.cloud.google.com/).
2. Open the Navigation Menu (☰) and select **Billing**.
3. If prompted, choose your Cloud Billing Account (e.g., `015205-208793-CA04DA`).
4. In the left navigation menu under **Cost management**, click **Budgets & alerts**.
5. Click **+ Create budget**.

### Step 2: Define Budget Scope
1. **Name:** Enter a descriptive name (e.g., `Monthly Account Spend Budget`).
2. **Time range:** Select **Monthly** (default).
3. **Projects:** Leave as **All projects** (or select specific projects).
4. **Services:** Leave as **All services**.
5. **Credits:** Check **Include all credits** (recommended to reflect actual net spend).
6. Click **Next**.

### Step 3: Set Budget Amount
1. **Budget type:** Select **Specified amount**.
2. **Target amount:** Enter your monthly spending limit (e.g. `2000.00`).
3. Click **Next**.

### Step 4: Configure Threshold Alert Rules
Add the alert trigger rules:

| Percent of Budget | Spend Basis | Description |
| :--- | :--- | :--- |
| **70%** | **Actual** | Triggers when spend reaches 70% of budget |
| **80%** | **Actual** | Triggers when spend reaches 80% of budget |
| **90%** | **Actual** | Triggers when spend reaches 90% of budget |
| **100%** | **Actual** | Triggers when spend reaches 100% of budget |
| **100%** | **Forecasted** | Triggers when projected spend exceeds 100% before month end |

*Tip: To add additional rules in the UI, click **+ Add threshold rule**.*

### Step 5: Configure Notifications & Save
1. Under **Manage notifications**:
   - Check **Email alerts to billing admins and users** to notify all billing administrators.
   - (Optional) Check **Link Cloud Monitoring notification channels** and select existing Slack, PagerDuty, or email channels.
   - (Optional) Check **Connect a Pub/Sub topic to this budget** if you have automated cost containment scripts (e.g., Cloud Functions).
2. Click **Finish**.

---

## License
Internal tooling for Google Cloud engineering.
