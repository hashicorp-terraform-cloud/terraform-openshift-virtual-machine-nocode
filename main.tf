resource "random_password" "vm_password" {
  length           = 16
  special          = true
  override_special = "_@-!$%^"
  upper            = true
  lower            = true
  numeric          = true
}

resource "random_uuid" "vm_uuid" {}

resource "kubernetes_service_account_v1" "vm" {
  metadata {
    name      = local.sa_name
    namespace = local.namespace
    labels    = local.hcp_labels
  }
}

resource "kubernetes_service_v1" "ssh" {
  metadata {
    name      = "${var.name}-vm-internal"
    namespace = local.namespace
    labels    = local.hcp_labels
  }

  spec {
    selector = {
      "terraform/uuid" = random_uuid.vm_uuid.result
    }
    port {
      port        = 22
      target_port = 22
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_manifest" "vm" {
  manifest = yamldecode(templatefile("${path.module}/templates/rhel.yaml.tftpl", {
    name      = var.name
    namespace = local.namespace

    vm_labels  = local.vm_labels
    pod_labels = local.pod_labels

    datasource_name      = var.os
    datasource_namespace = "openshift-virtualization-os-images"

    cpu_cores   = local.profile.cores
    cpu_sockets = local.profile.sockets
    cpu_threads = 1
    memory      = local.profile.memory
    disk_size   = local.profile.disk

    cloud_user          = local.cloud_user
    cloud_user_password = local.vm_password

    service_account_name = kubernetes_service_account_v1.vm.metadata[0].name

    size_profile = var.size_profile
    machine_type = "pc-q35-rhel9.4.0"
    run_strategy = "RerunOnFailure"
  }))

  # KubeVirt's admission webhook mutates these on apply; let SSA reconcile them.
  computed_fields = [
    "metadata.annotations",
    "metadata.labels",
    "spec.template.spec.domain.devices.disks",
    "spec.template.spec.domain.machine.type",
    "spec.dataVolumeTemplates",
  ]
}
