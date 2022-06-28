

# This is used in VM tags for "vm_group_name"
# and has "avi-" prepended
# and has "-controller" or "-se" appended
variable "deployment_name" {
  type = string
  default = "deployment-1"
}


# vSphere settings

variable "vsphere_datacenter" {
  type    = string
}

variable "vsphere_cluster" {
  type    = string
}

variable "esxi_vm_name" {
  type    = string
}

variable "vsphere_username" {
  type = string
  default = "administrator@vsphere.local"
}

variable "vsphere_password" {
  type = string
  sensitive = true
}
variable "vsphere_insecure" {
  type = bool
  default = false
}

variable "vsphere_hostname" {
  type = string
}

variable "vsphere_api_timeout" {
  type = number
  default = 60
}


variable "vsphere_vm_datastore" {
  type = string
}
variable "vsphere_vm_folder" {
  type = string
}

# Networking settings

variable "management_network_name" {
  type = string
}
variable "management_dns_server" {
  type = string
}
variable "management_ntp_server1" {
  type = string
}
variable "management_domain" {
  type = string
}
variable "management_start_ipv4" {
  type = string
}
variable "management_end_ipv4" {
  type = string
}
variable "management_network_ipv4" {
  type = string
}
variable "management_subnet_mask_int" {
  type = number
}
variable "management_subnet_mask_long" {
  type = string
}
variable "management_default_gateway" {
  type = string
}

variable "data_network_name" {
  type = string
}
# variable "data_dns_server" {
#   type = string
# }
# variable "data_ntp_server1" {
#   type = string
# }
# variable "data_domain" {
#   type = string
# }
variable "data_network_start_ipv4" {
  type = string
}
variable "data_network_end_ipv4" {
  type = string
}
variable "data_network_address_count" {
  type = number
}
variable "data_network_ipv4" {
  type = string
}
variable "data_network_subnet_mask_int" {
  type = number
}
# variable "data_subnet_mask_long" {
#   type = string
# }
variable "data_network_default_gateway" {
  type = string
}

variable "workload_network_name" {
  type = string
}
variable "workload_dns_server" {
  type = string
}
variable "workload_ntp_server1" {
  type = string
}
variable "workload_start_ipv4" {
  type = string
}
variable "workload_address_count" {
  type = number
}
# variable "workload_end_ipv4" {
#   type = string
# }
variable "workload_network_ipv4" {
  type = string
}
variable "workload_subnet_mask_int" {
  type = number
}
variable "workload_subnet_mask_long" {
  type = string
}
variable "workload_default_gateway" {
  type = string
}




// Avi settings

variable "avi_username" {
  type = string
  default = "admin"
}

variable "avi_password" {
  type = string
  sensitive = true
}

// New variables for full OVA settings:-
// TODO support multiple avi controllers
# Name for the controller VM (MAY also be its hostname (or FQDN))
variable "avi_management_hostname" {
  type = string
}
variable "avi_management_address_ipv4" {
  type = string
}
variable "avi_management_port" {
  type = number
  default = 443
}
# More variables for configuring deployment of Avi:-

variable "avi_version" {
  type = string
}
variable "avi_tenant" {
  type = string
  # DO NOT CHANGE THIS YET
  default = "admin"
}

variable "avi_content_library" {
  type = string
}
variable "avi_vm_template" {
  type = string
}
variable "avi_vm_resource_pool" {
  type = string
  default = "AVI_CTRL"
}
variable "avi_vm_name" {
  type = string
}

variable "avi_cloud_name" {
  type = string
  # DO NOT USE Default-Cloud UNDER ANY CIRCUMSTANCES
  # Terraform delete does NOT reset Default-Cloud
  # default = "Default-Cloud"
  # default = "vSphere-Cloud"
}
variable "avi_se_group_name" {
  type = string
}


# Licensing related variables
# Note: if true, requires an Avi Enterprise (not essentials) license
variable "avi_prefer_static_routes" {
  type = bool
  default = true
}

# System config elements for confirmation
variable "avi_backup_passphrase" {
  type = string
  sensitive = true
}



# TANZU specific settings

variable "tanzu_image_storage_policy_name" {
  type = string
}
variable "tanzu_supervisor_storage_policy_name" {
  type = string
}
variable "tanzu_ephemeral_storage_policy_name" {
  type = string
}
variable "tanzu_default_kubernetes_service_content_library_name" {
  type = string
}

variable "tanzu_supervisor_start_ipv4" {
  type = string
}
variable "tanzu_supervisor_address_count" {
  type = number
  default = 5
}
variable "tanzu_supervisor_dns_names" {
  type = string
}

variable "tanzu_service_cidr_network" {
  type = string
  default = "10.96.0.0"
}
variable "tanzu_service_cidr_mask" {
  type = number
  default = 23
}

variable "tanzu_network_ip_assignment_mode" {
  type = string
  default = ""
}
