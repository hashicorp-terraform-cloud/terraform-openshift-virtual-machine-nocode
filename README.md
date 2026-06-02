# OpenShift Virtualization VM — No-Code Module

A No-Code Terraform module for HCP Terraform that provisions a RHEL-family virtual machine on OpenShift Virtualization. End users interact with a four-field form; everything else is supplied by a project-scoped variable set.

This is the No-Code variant of [`terraform-kubernetes-openshift-virtual-machine-rhel`](../terraform-kubernetes-openshift-virtual-machine-rhel/). The original module remains available for power users who want the full set of knobs.

## What this module does

Provisions, in the user's OCP project:

- A `VirtualMachine` (`kubevirt.io/v1`) backed by a DataVolume cloned from a cluster `DataSource`.
- A `ServiceAccount` mounted into the VM at `/var/run/secrets/kubernetes.io/serviceaccount` so workloads inside the VM can assume an in-cluster identity.
- A ClusterIP `Service` exposing the VM on port 22 at `<vm-name>.<namespace>.svc.cluster.local`.

It also reads the tags on the **HCP Terraform project** the workspace belongs to and mirrors them onto every Kubernetes resource as labels, so platform-team tagging carries through to the infrastructure automatically.

## End-user form (4 fields)

| Field | Type | Default | Notes |
|---|---|---|---|
| `name` | string | — | DNS-1123 label. Becomes the VM name and hostname. |
| `namespace` | string | — | OCP project the VM is created in. |
| `os` | dropdown | `rhel9` | `rhel8`, `rhel9`, `centos-stream9`, `centos-stream10`, `fedora`. |
| `size_profile` | dropdown | `small` | `tiny`, `small`, `medium`, `large`. See sizing below. |

Everything else is hidden — pinned to sensible defaults, derived from the OS or size profile, or supplied by the variable set.

## Size profiles

| Profile | vCPU (sockets × cores) | Memory | Disk |
|---|---|---|---|
| `tiny` | 1 × 1 = 1 | 1Gi | 30Gi |
| `small` | 2 × 1 = 2 | 4Gi | 30Gi |
| `medium` | 2 × 2 = 4 | 8Gi | 60Gi |
| `large` | 2 × 4 = 8 | 16Gi | 100Gi |

`small` matches the existing standard module's defaults, so behaviour is preserved for the typical case.

## Cloud-init user (derived from `os`)

| `os` value | cloud-init user |
|---|---|
| `rhel8`, `rhel9` | `cloud-user` |
| `centos-stream9`, `centos-stream10` | `centos` |
| `fedora` | `fedora` |

The auto-generated password is surfaced via the `vm_credentials` output.

## Platform-team setup: variable set

Before publishing this module as No-Code, create a **project-scoped variable set** containing the following and attach it to every HCP Terraform project that should be allowed to provision VMs.

### Environment variables

| Name | Sensitive | Purpose |
|---|---|---|
| `KUBE_HOST` | no | OCP API endpoint (e.g. `https://api.cluster.example.com:6443`). |
| `KUBE_TOKEN` | **yes** | Bearer token for an OCP service account with permissions to create VMs, Services, and ServiceAccounts in target namespaces. |
| `KUBE_INSECURE` | no | `true` to skip TLS verification, `false` otherwise. |
| `TFE_TOKEN` | **yes** | HCP Terraform token with at least `read` access to the project (used to look up project tags). A team token scoped to the project is sufficient. |

### Terraform variables

| Name | Value |
|---|---|
| `tfe_organization` | The HCP Terraform organization name. |
| `tfe_project_name` | The HCP Terraform project name. Must match the project the variable set is attached to. |

Both Terraform variables will appear on the no-code form pre-filled by the variable set; their descriptions instruct users not to change them.

## Outputs

| Output | Purpose |
|---|---|
| `vm_name`, `vm_namespace` | Convenience echoes of the inputs. |
| `vm_credentials` | `{ user, password }` for SSH login. `password` is intentionally surfaced non-sensitive so it renders in the workspace UI. |
| `vm_resources` | `{ cpu_total, memory, disk }` showing the effective allocation from `size_profile`. |
| `vm_service_cluster_ip` / `vm_service_cluster_ips` | ClusterIP(s) of the SSH service. |
| `vm_service_hostname` | In-cluster FQDN: `<name>.<namespace>.svc.cluster.local`. |
| `service_account` | `{ name, namespace }` of the SA mounted into the VM. |
| `mirrored_labels` | The HCP TF project tags that were mirrored onto the VM (sanitized for K8s label rules). |

## Accessing the VM

From any pod inside the same OCP cluster:

```sh
ssh cloud-user@my-vm.my-project.svc.cluster.local
# password from the workspace's vm_credentials output
```

(Use `centos` or `fedora` instead of `cloud-user` if you chose a non-RHEL `os`.)

## Differences from the standard module

This variant deliberately diverges from [`terraform-kubernetes-openshift-virtual-machine-rhel`](../terraform-kubernetes-openshift-virtual-machine-rhel/) in the following ways:

- **No Vault SSH CA integration.** The standard module supports fetching a CA public key from a URI (typically Vault's `ssh-client-signer`) and wiring it into `/etc/ssh/trusted-user-ca-keys.pem`. The No-Code variant uses password auth only.
- **No `kubectl` provider.** Uses `kubernetes_manifest` from the official `hashicorp/kubernetes` provider for the VM CRD, plus typed `kubernetes_service_account_v1` and `kubernetes_service_v1` resources.
- **Service Account binding is always on.** No opt-out.
- **Cluster-reachability at plan time.** `kubernetes_manifest` requires API access during planning, so wrong credentials fail fast on plan rather than mid-apply.
- **HCP project tags become K8s labels.** Not present in the standard module.

## Provider versions

| Provider | Constraint |
|---|---|
| `hashicorp/kubernetes` | `~> 3.1` |
| `hashicorp/random` | `~> 3.9` |
| `hashicorp/tfe` | `~> 0.77` |
| Terraform | `>= 1.0` |
