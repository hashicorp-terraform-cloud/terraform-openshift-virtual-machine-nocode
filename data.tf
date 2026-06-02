data "tfe_project" "current" {
  name         = var.tfe_project_name
  organization = var.tfe_organization
}
