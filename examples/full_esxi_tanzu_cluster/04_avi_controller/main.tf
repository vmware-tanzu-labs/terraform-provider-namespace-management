terraform {
  required_providers {
    avi = {
      # version = ">= 21.1"
      source  = "vmware/avi"
    }
    vsphere = {
      version = ">= 2.1.1"
      source = "hashicorp/vsphere"
    }
  }
}

data "vsphere_datacenter" "dc" {
  name = var.vm_datacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.vm_datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  name          = var.vm_resource_pool
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.vm_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_content_library" "library" {
  name = var.content_library
}

data "vsphere_content_library_item" "item" {
  name       = var.vm_template
  library_id = data.vsphere_content_library.library.id
  type = "" // Is actually a Read item, not a set one
}

# TODO multiple servers See https://github.com/vmware/terraform-provider-avi/blob/69020e02183968fd05244eb9b11cd9fb89747706/modules/nia/pool/main.tf#L72

resource "vsphere_virtual_machine" "vm" {
  // For settings with vSphere networking:-
  // See: https://docs.vmware.com/en/VMware-vSphere/7.0/vmware-vsphere-with-tanzu/GUID-CBA041AB-DC1D-4EEC-8047-184F2CF2FE0F.html

  // Is name the same as hostname? (doubtful - VM name in vCenter)
  name             = "${var.vm_name}-${count.index+1}"
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  count = 1
  num_cpus = 4
  memory = 24576
  folder = var.vm_folder
  // Management network (only interface in OVA)
  // TODO determine if OVA setting is automatically linked to this
  network_interface {
    network_id   = data.vsphere_network.network.id
  }
  lifecycle {
    ignore_changes = [guest_id]
  }
  disk {
    label = "disk1"
    size = 130
    // Thin unless you have a very good reason not to
    thin_provisioned = true
  }
  clone {
    template_uuid = data.vsphere_content_library_item.item.id
  }
  vapp {
    properties = {
      // Missing from Avi examples, but in the OVA:-
      // TODO how to do NTP, DNS, search domain???
      # dns_server_list = [var.avi_management_dns_server]
      # dns_suffix_list = [var.avi_management_dns_suffix]
      # linux_options {
      #   host_name = var.avi_management_hostname
      #   domain    = var.avi_management_domain
      # }

      // Hostname for the controller vm
      // OVA Docs: Hostname of Avi controller (For modification by NSX Manager only. This field should not be filled in or modified by the user directly)
      hostname = var.avi_management_hostname
      // OVA Docs: IP address for the Management Interface. Leave blank if using DHCP. Example: 192.168.10.4
      // Tanzu Docs: Enter the IP address for the [this] Controller VM, such as 10.999.17.51.
      // REQUIRED field if DHCP is not being used (which normally it isn't for a controller)
      mgmt-ip = var.avi_management_ip_address
      // OVA Docs: Subnet mask for the Management Interface. Leave blank if using DHCP. Example : 24 or 255.255.255.0
      // Tanzu Docs: Enter the subnet mask, such as 255.255.255.0.
      // REQUIRED if management ip specified (Static IP)
      mgmt-mask = var.avi_management_subnet_mask_int
      // OVA Docs: Optional default gateway for the Management Network. Leave blank if using DHCP.
      // Tanzu Docs: Enter the default gateway for the Management Network, such as 10.199.17.235.
      // REQUIRED if management ip specified (Static IP)
      default-gw = var.avi_management_default_gateway

      // OVA Docs: Sysadmin login authentication key
      // Tanzu Docs: Paste the contents of a private key (optional).
      //   This is the private SSH key that you require to SSH into the VM. You can create it using OpenSSH or PuTTY.
      // Optional: Don't specify for now. sysadmin-public-key = var.avi_management_ssh_key
      // NSX-T Node ID
      // OVA Docs: NSX-T Node ID to uniquely identify node in a NSX-T cluster (For modification by NSX Manager only. This field should not be filled in or modified by the user directly)
      // nsx-t-node-id = ""
      // NSX-T IP Address
      // OVA Docs: IP address of the NSX-T which will manage this controller (For modification by NSX Manager only. This field should not be filled in or modified by the user directly)
      // nsx-t-ip = ""
      // Authentication token of NSX-T
      // OVA Docs: Authentication token of the NSX-T which will manage this controller (For modification by NSX Manager only. This field should not be filled in or modified by the user directly)
      // nsx-t-auth-token = ""
      // NSX-T thumbprint
      // OVA Docs: Thumbprint of the MP node of NSX-T which will manage this controller (For modification by NSX Manager only. This field should not be filled in or modified by the user directly)
      // nsx-t-thumbprint = ""
    } // properties
  } // vapp
  wait_for_guest_ip_timeout = 30
}

provider "avi" {
  avi_username   = var.avi_username
  avi_password   = "58NFaGDJm(PJH0G"
  # avi_controller = vsphere_virtual_machine.vm[0].default_ip_address
  avi_tenant     = "admin"

  # For after creation by vsphere
  avi_controller = var.avi_management_ip_address

  # Required for Terraform provider not to puke
  # Without this it complains about 'common_criteria' being there (even though false by default) as the terraform provider defaults to v18.8
  avi_version = "21.1.2"
}

# Can take up to 11 minutes approximately before Avi responds
data "avi_systemconfiguration" "ensure_server_responding" {
  depends_on = [vsphere_virtual_machine.vm]
}


# WARNING ENSURE THIS IS THE LAST SO AS NOT TO PUKE ON RETRY

resource "avi_useraccount" "avi_user" {
  username     = var.avi_username
  name     = var.avi_username
  # id     = var.avi_username
  # Stupidly, the provider relies on old and new password differing, and not being empty
  old_password = "58NFaGDJm(PJH0G"
  # Even more stupidly, since v17.2.2 the default admin password is a hardcoded value available from the customer portal. This is NOT DOCUMENTED in ANY of the terraform examples from Avi
  password     = var.avi_password

  depends_on = [data.avi_systemconfiguration.ensure_server_responding]
}

# resource "avi_user" "avi_user" {
#   # id = var.avi_username
#   name = var.avi_username
#   uuid = var.avi_username
#   # username     = var.avi_username
#   password     = var.avi_password

#   depends_on = [data.avi_systemconfiguration.ensure_server_responding]
# }


# TODO vm-vm host anti-affinity groups for Avi-Controller VMs


# Maybe output the full calculated tag values too for VMs
# output "avi_cluster_output" {
#   value = avi_cluster.vmware_cluster
# }

output "initial_configuration" {
  value = data.avi_systemconfiguration.ensure_server_responding
}

output "admin_user" {
  value = avi_useraccount.avi_user
}