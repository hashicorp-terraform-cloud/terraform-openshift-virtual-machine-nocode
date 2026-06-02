terraform {
  required_version = ">= 1.0"

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
  }
}
