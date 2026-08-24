output "budget_id" {
  description = "The ID of the created budget alert."
  value       = module.project_budget.budget_id
}

output "budget_name" {
  description = "The resource name of the created budget alert."
  value       = module.project_budget.budget_name
}
