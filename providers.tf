# host comes from the KUBE_HOST env; the CA is supplied base64-encoded and decoded
# here; the token is minted per run from Vault for the project's namespace-admin
# service account.
provider "kubernetes" {
  cluster_ca_certificate = base64decode(var.openshift_ca_cert_base64)
  token                  = ephemeral.vault_kubernetes_service_account_token.ocp.service_account_token
}

# HCP TF Vault dynamic credentials (TFC_VAULT_*); targets the Vault namespace
# holding the Kubernetes secrets engine via TFC_VAULT_NAMESPACE.
provider "vault" {}

provider "tfe" {}
