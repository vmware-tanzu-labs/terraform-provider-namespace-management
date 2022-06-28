terraform {
  required_providers {
    vsphere = {
      version = ">= 2.1.1"
      source = "hashicorp/vsphere"
    }
  }
}

variable "cluster_name" {
  default = "DC0_C0"
}

variable "datacenter_name" {
  default = "DC0"
}

variable "esxi_hosts" {
  default = [
    "DC0_C0_H0",
    "DC0_C0_H1",
    "DC0_C0_H2",
    # "vesxi01.lab01.my.cloud",
    # "vesxi02.lab01.my.cloud",
    # "vesxi03.lab01.my.cloud",
  ]
}

data "vsphere_datacenter" "dc" {
  name = "${var.datacenter_name}"
}

# data "vsphere_host" "hosts" {
#   count         = "${length(var.esxi_hosts)}"
#   name          = "${var.esxi_hosts[count.index]}"
#   datacenter_id = data.vsphere_datacenter.dc.id
# }

# data "vsphere_host" "esxi01_id" {
#   name = "${var.esxi_hosts[0]}"
#   datacenter_id = data.vsphere_datacenter.dc.id
# }

# data "vsphere_host" "esxi02_id" {
#   name = "${var.esxi_hosts[1]}"
#   datacenter_id = data.vsphere_datacenter.dc.id
# }

# data "vsphere_host" "esxi03_id" {
#   name = "${var.esxi_hosts[2]}"
#   datacenter_id = data.vsphere_datacenter.dc.id
# }

# data "vsphere_host" "dummy_id" {
#   name = "DC0_H0"
#   datacenter_id = data.vsphere_datacenter.dc.id
# }

resource "vsphere_compute_cluster" "compute_cluster" {
  name            = var.cluster_name
  datacenter_id   = data.vsphere_datacenter.dc.id
  # host_system_ids = [data.vsphere_host.esxi01_id.id,data.vsphere_host.esxi02_id.id,data.vsphere_host.esxi03_id.id]
  # host_system_ids = [data.vsphere_host.dummy_id.id]
  host_managed = true

  # TODO TRY AGAINST A H20 INSTANCE NEXT
  # THEN (IF BRAVE) RUN AGAINST MY LIVE SERVER VIA WIREGUARD

  drs_enabled          = true
  drs_automation_level = "fullyAutomated"

  ha_enabled = false
}

// ADD host and place into maintenance most
resource "vsphere_host" "esxi01" {
  hostname = var.esxi_hosts[0]
  username   = "root"
  password   = "pass"
  cluster = vsphere_compute_cluster.compute_cluster.id
  force = true
}
resource "vsphere_host" "esxi02" {
  hostname = "${var.esxi_hosts[1]}"
  username   = "root"
  password   = "pass"
  cluster = vsphere_compute_cluster.compute_cluster.id
  force = true
}
resource "vsphere_host" "esxi03" {
  hostname = "${var.esxi_hosts[2]}"
  username   = "root"
  password   = "pass"
  cluster = vsphere_compute_cluster.compute_cluster.id
  force = true
}

// TODO remove hosts from maintenance mode

output "cluster" {
  value = resource.vsphere_compute_cluster.compute_cluster.id
}