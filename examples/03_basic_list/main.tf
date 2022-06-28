terraform {
  required_providers {
    // Force local binary use, rather than public binary
    namespace-management = {
      version = ">= 0.1"
      source  = "vmware.com/vcenter/namespace-management"
    }
  }
}

provider "namespace-management" {
  vsphere_hostname = "vc01.h2o-4-328.h2o.vmware.com"
  vsphere_username = "Administrator@vsphere.local"
  vsphere_password = "" # SET ME

  # If you have a self-signed cert
  vsphere_insecure = true
  # TODO support custom cert/ca bundle
}

variable "cluster_name" {
  default = "vc01cl01"
}
variable "datacenter_name" {
  default = "vc01"
}

# THIS SAMPLE JUST READS ALL CONFIGURES SUPERVISOR CLUSTERS
module "clusters" {
  source = "./clusters"
}

output "clusters" {
  value = module.clusters.clusters
}
