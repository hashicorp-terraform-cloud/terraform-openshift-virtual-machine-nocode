variable "name" {
  description = "Name of the virtual machine (also used as hostname)."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.name)) && length(var.name) <= 63
    error_message = "Name must be a valid DNS-1123 label: lowercase alphanumerics and hyphens, must start and end with an alphanumeric, max 63 chars."
  }
}

variable "os" {
  description = "Guest OS image. Drives the DataSource reference and the default cloud-init user."
  type        = string

  validation {
    condition = contains([
      "rhel8",
      "rhel9",
      "centos-stream9",
      "centos-stream10",
      "fedora",
    ], var.os)
    error_message = "Supported values: rhel8, rhel9, centos-stream9, centos-stream10, fedora."
  }
}

variable "size_profile" {
  description = "VM sizing profile. Drives CPU sockets/cores, memory, root disk, and KubeVirt size/flavor labels."
  type        = string

  validation {
    condition     = contains(["tiny", "small", "medium", "large"], var.size_profile)
    error_message = "Supported values: tiny, small, medium, large."
  }
}

# Platform-managed inputs - populated by the project-scoped HCP TF variable set.
# These identify which HCP TF project this workspace lives under so its tags can
# be mirrored onto the VM as Kubernetes labels.

variable "tfe_organization" {
  description = "HCP Terraform organization name. Managed by the platform team via variable set - do not change."
  type        = string

  validation {
    condition     = length(trimspace(var.tfe_organization)) > 0
    error_message = "tfe_organization must not be empty. This value is supplied by the project-scoped variable set."
  }
}

variable "project_name" {
  description = "HCP Terraform project name. Managed by the platform team via variable set - do not change."
  type        = string
  default     = null

  validation {
    condition     = var.project_name != null && length(trimspace(var.project_name)) > 0
    error_message = "project_name must not be empty. This value is supplied by the project-scoped variable set."
  }
}

variable "vault_kubernetes_backend" {
  description = "Vault Kubernetes secrets engine mount path. Managed by the platform team via variable set."
  type        = string
  default     = "openshift"
}

variable "openshift_ca_cert_base64" {
  description = "Base64-encoded PEM CA certificate for the OpenShift API server. Managed by the platform team."
  type        = string
}
