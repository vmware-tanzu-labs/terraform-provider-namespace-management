terraform {
  required_providers {
    // Force local binary use, rather than public binary
    namespace-management = {
      version = "0.1"
      source  = "vmware.com/vcenter/namespace-management"
    }
    vsphere = {
      version = ">= 2.1.1"
      source = "hashicorp/vsphere"
    }
  }
}

variable "cluster_name" {
  type    = string
  default = "Cluster01"
}
variable "datacenter_name" {
  type    = string
  default = "lab01.my.cloud"
}

data "vsphere_datacenter" "dc" {
  name = var.datacenter_name
}

# Converts the vSphere cluster name to its id
data "vsphere_compute_cluster" "fetch" {
  name = var.cluster_name
  datacenter_id = data.vsphere_datacenter.dc.id
}
# ALTERNATIVE to the above (if it already exists!):-
# data "namespace-management_cluster" "fetch" {
#   name = var.cluster_name
#   # Note: No need for datacenter_id in this API
# }

# Enables the Tanzu Supervisor Cluster
resource "namespace-management_cluster" "supervisor" {
  id = data.vsphere_compute_cluster.fetch.id
  # If using the alternative cluster lookup method:-
  # id = data.namespace-management_cluster.fetch.id

  # TODO other settings here (Hardcoded in the provider today)
}

# Only the newly enabled cluster (including the cluster ID)
output "cluster" {
  value = data.namespace-management_cluster.supervisor
}

# Convenience output for future commands
output "datacenter_id" {
  values = data.vsphere_datacenter.dc.id
}