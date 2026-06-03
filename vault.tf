# Short-lived OpenShift token for this run, minted by Vault's Kubernetes secrets
# engine for the project's tf-admin (namespace-admin) service account. Ephemeral,
# so it is never written to state. role and namespace both equal the project name.
ephemeral "vault_kubernetes_service_account_token" "ocp" {
  backend              = var.vault_kubernetes_backend
  role                 = var.project_name
  kubernetes_namespace = local.namespace
}
