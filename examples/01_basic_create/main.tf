terraform {
  required_providers {
    // Force local binary use, rather than public binary
    namespace-management = {
      version = ">= 0.1"
      source  = "vmware.com/vcenter/namespace-management"
    }
    vsphere = {
      version = ">= 2.1.1"
      source = "hashicorp/vsphere"
    }
  }
}

provider "namespace-management" {
  vsphere_hostname = "https://vc01.h2o-4-328.h2o.vmware.com/sdk"
  vsphere_username = "Administrator@vsphere.local"
  vsphere_password = "" # SET ME

  # If you have a self-signed cert
  vsphere_insecure = true
  # TODO support custom cert/ca bundle
}
provider "vsphere" {
  vsphere_server = "https://vc01.h2o-4-328.h2o.vmware.com/sdk"
  user           = "Administrator@vsphere.local"
  password       = "" # SET ME

  # If you have a self-signed cert
  allow_unverified_ssl = true
  # TODO support custom cert/ca bundle
}

variable "cluster_name" {
  default = "vc01cl01"
}
variable "datacenter_name" {
  default = "vc01"
}

module "clusters" {
  source = "./clusters"

  cluster_name = var.cluster_name
  datacenter_name = var.datacenter_name
}

output "cluster" {
  value = module.clusters.cluster
}
