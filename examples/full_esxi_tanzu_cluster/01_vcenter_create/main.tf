terraform {
  required_providers {
    vsphere = {
      version = ">= 2.1.1"
      source = "hashicorp/vsphere"
    }
  }
}
variable "datacenter" {
  default = "lab01.my.cloud"
}

variable "esxi_hosts" {
  default = [
    "vesxi01.lab01.my.cloud",
    "vesxi02.lab01.my.cloud",
    "vesxi03.lab01.my.cloud",
  ]
}

resource "vsphere_datacenter" "dc" {
  name = "${var.datacenter}"
}

resource "vsphere_host" "esxi01" {
  hostname = "${var.esxi_hosts[0]}"
  username   = "root"
  password   = "pass"
  # license    = "00000-00000-00000-00000i-00000"
  datacenter = resource.vsphere_datacenter.dc.id
  # connected = true
  # lockdown = "normal"
  # maintenance = true
}

resource "vsphere_host" "esxi02" {
  hostname = "${var.esxi_hosts[1]}"
  username   = "root"
  password   = "pass"
  # license    = "00000-00000-00000-00000i-00000"
  datacenter = resource.vsphere_datacenter.dc.id
  # connected = true
  # lockdown = "normal"
  # maintenance = true
}

resource "vsphere_host" "esxi03" {
  hostname = "${var.esxi_hosts[2]}"
  username   = "root"
  password   = "pass"
  # license    = "00000-00000-00000-00000i-00000"
  datacenter = resource.vsphere_datacenter.dc.id
  # connected = true
  # lockdown = "normal"
  # maintenance = true
}

output "datacenter" {
  value = resource.vsphere_datacenter.dc.id
}

output "hosts" {
  value = [resource.vsphere_host.esxi01.id,resource.vsphere_host.esxi02.id,resource.vsphere_host.esxi03.id]
}