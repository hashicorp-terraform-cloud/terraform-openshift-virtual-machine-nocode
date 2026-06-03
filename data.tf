data "tfe_project" "current" {
  name         = var.project_name
  organization = var.tfe_organization
}
