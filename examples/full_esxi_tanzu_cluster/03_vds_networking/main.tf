terraform {
  required_providers {
    vsphere = {
      version = ">= 2.1.1"
      source = "hashicorp/vsphere"
    }
  }
}

variable "esxi_hosts" {
  default = [
    "vesxi01.lab01.my.cloud",
    "vesxi02.lab01.my.cloud",
    "vesxi03.lab01.my.cloud",
  ]
}

variable "management_network_interfaces" {
  default = [
    "vmnic0"
  ]
}

variable "workload_network_interfaces" {
  default = [
    "vmnic2",
  ]
}

data "vsphere_datacenter" "datacenter" {
  name = "lab01.my.cloud"
}

data "vsphere_host" "host" {
  count         = length(var.esxi_hosts)
  name          = var.esxi_hosts[count.index]
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_distributed_virtual_switch" "management" {
  name            = "Management vSwitch"
  datacenter_id   = data.vsphere_datacenter.datacenter.id
  # max_mtu         = 1500

  # uplinks         = ["uplink1"]
  # active_uplinks  = ["uplink1"]
  # standby_uplinks = []

  # host {
  #   host_system_id = data.vsphere_host.host.0.id
  #   devices        = ["${var.management_network_interfaces}"]
  # }

  # host {
  #   host_system_id = data.vsphere_host.host.1.id
  #   devices        = ["${var.management_network_interfaces}"]
  # }

  # host {
  #   host_system_id = data.vsphere_host.host.2.id
  #   devices        = ["${var.management_network_interfaces}"]
  # }
}

resource "vsphere_distributed_port_group" "management_portgroup" {
  name                            = "Management Network"
  distributed_virtual_switch_uuid = data.vsphere_distributed_virtual_switch.management.id

  vlan_id = 11
}

# data "vsphere_distributed_virtual_switch" "workload" {
#   name            = "Workload vSwitch"
#   datacenter_id   = data.vsphere_datacenter.datacenter.id
#   # max_mtu         = 9000

#   uplinks         = ["uplink1","uplink2"]
#   active_uplinks  = ["uplink1"]
#   standby_uplinks = ["uplink2"]

#   host {
#     host_system_id = data.vsphere_host.host.0.id
#     devices        = ["${var.workload_network_interfaces}"]
#   }

#   host {
#     host_system_id = data.vsphere_host.host.1.id
#     devices        = ["${var.workload_network_interfaces}"]
#   }

#   host {
#     host_system_id = data.vsphere_host.host.2.id
#     devices        = ["${var.workload_network_interfaces}"]
#   }
# }

# resource "vsphere_distributed_port_group" "workload_portgroup" {
#   name                            = "Distributed VM Network"
#   distributed_virtual_switch_uuid = vsphere_distributed_virtual_switch.workload.id

#   vlan_id = 1000
# }

# Returns all clusters
output "management_vswitch" {
  value = data.vsphere_distributed_virtual_switch.management.id
}

# # Only returns Cluster01
# output "workload_vswitch" {
#   value = data.vsphere_distributed_virtual_switch.workload.id
# }
