terraform {
  required_providers {
    // Force local binary use, rather than public binary
    namespace-management = {
      version = ">= 0.1"
      source  = "vmware.com/vcenter/namespace-management"
    }
  }
}

# Fetches the namespace cluster summary (if found)
data "namespace-management_clusters" "read" {
}

# Returns all clusters
output "clusters" {
  value = data.namespace-management_clusters.read
}
