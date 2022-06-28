terraform {
  required_providers {
    // Force local binary use, rather than public binary
    namespace-management = {
      version = ">= 0.1"
      source  = "vmware.com/vcenter/namespace-management"
    }
  }
}

variable "cluster_name" {
  type    = string
  default = "Cluster01"
}

# Fetches the namespace cluster summary (if found)
data "namespace-management_cluster" "read" {
  name = var.cluster_name
}

# Only returns Cluster01
output "cluster" {
  value = data.namespace-management_cluster.read
}
