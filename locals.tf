locals {
  size_profiles = {
    tiny = {
      sockets = 1
      cores   = 1
      memory  = "1Gi"
      disk    = "30Gi"
    }
    small = {
      sockets = 2
      cores   = 1
      memory  = "4Gi"
      disk    = "30Gi"
    }
    medium = {
      sockets = 2
      cores   = 2
      memory  = "8Gi"
      disk    = "60Gi"
    }
    large = {
      sockets = 2
      cores   = 4
      memory  = "16Gi"
      disk    = "100Gi"
    }
  }
  profile = local.size_profiles[var.size_profile]

  cloud_user_map = {
    rhel8           = "cloud-user"
    rhel9           = "cloud-user"
    centos-stream9  = "centos"
    centos-stream10 = "centos"
    fedora          = "fedora"
  }
  cloud_user = local.cloud_user_map[var.os]

  sa_name     = "${var.name}-sa"
  vm_password = random_password.vm_password.result

  raw_project_tags = data.tfe_project.current.effective_tags

  hcp_labels = {
    for k, v in local.raw_project_tags :
    substr(replace(lower(k), "/[^a-z0-9._-]/", "-"), 0, 63)
    =>
    substr(replace(v, "/[^a-zA-Z0-9._-]/", "-"), 0, 63)
    if length(trimspace(k)) > 0
  }

  vm_labels = merge(
    local.hcp_labels,
    { app = var.name },
  )

  pod_labels = merge(
    local.hcp_labels,
    {
      "kubevirt.io/domain"                  = var.name
      "kubevirt.io/size"                    = var.size_profile
      "network.kubevirt.io/headlessService" = "headless"
      "terraform/uuid"                      = random_uuid.vm_uuid.result
    },
  )
}
