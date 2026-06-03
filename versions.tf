terraform {
  required_version = ">= 1.10.0" # ephemeral resources

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.9"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.77"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 5.9"
    }
  }
}
