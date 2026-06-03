# host and CA come from KUBE_HOST / KUBE_CLUSTER_CA_CERT_DATA env; the token is
# minted per run from Vault for the project's namespace-admin service account.
provider "kubernetes" {
  token = ephemeral.vault_kubernetes_service_account_token.ocp.service_account_token
}

# HCP TF Vault dynamic credentials (TFC_VAULT_*); targets the Vault namespace
# holding the Kubernetes secrets engine via TFC_VAULT_NAMESPACE.
provider "vault" {}

provider "tfe" {}
