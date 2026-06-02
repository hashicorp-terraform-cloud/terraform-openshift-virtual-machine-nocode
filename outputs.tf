output "vm_name" {
  description = "Name of the created virtual machine."
  value       = var.name
}

output "vm_namespace" {
  description = "Namespace the virtual machine was created in."
  value       = var.namespace
}

output "vm_credentials" {
  description = "Login credentials for the cloud-init user."
  value = {
    user     = local.cloud_user
    password = nonsensitive(local.vm_password)
  }
}

output "vm_resources" {
  description = "Effective VM resource allocation (derived from size_profile)."
  value = {
    cpu_total = local.profile.cores * local.profile.sockets
    memory    = local.profile.memory
    disk      = local.profile.disk
  }
}

output "vm_service_cluster_ip" {
  description = "Primary ClusterIP of the in-cluster SSH service."
  value       = kubernetes_service_v1.ssh.spec[0].cluster_ip
}

output "vm_service_cluster_ips" {
  description = "All ClusterIPs of the in-cluster SSH service."
  value       = kubernetes_service_v1.ssh.spec[0].cluster_ips
}

output "vm_service_hostname" {
  description = "In-cluster DNS hostname for SSH access."
  value       = "${kubernetes_service_v1.ssh.metadata[0].name}.${var.namespace}.svc.cluster.local"
}

output "service_account" {
  description = "Service Account mounted into the VM at /var/run/secrets/kubernetes.io/serviceaccount."
  value = {
    name      = kubernetes_service_account_v1.vm.metadata[0].name
    namespace = kubernetes_service_account_v1.vm.metadata[0].namespace
  }
}

output "mirrored_labels" {
  description = "HCP Terraform project tags that were mirrored onto the VM as Kubernetes labels."
  value       = local.hcp_labels
}
