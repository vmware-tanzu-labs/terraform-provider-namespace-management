
variable "datacenter_name" {
  type    = string
  # default = "lab01.my.cloud"
}
# THE VSPHERE CLUSTER NAME (converted to ID in main.tf)
variable "cluster_name" {
  type = string
}
# variable "cluster_id" {
#   type = string
# }
variable "image_storage_policy_name" {
  type = string
}
# variable "image_storage_policy_id" {
#   type = string
# }
variable "master_storage_policy_name" {
  type = string
}
# variable "master_storage_policy_id" {
#   type = string
# }
variable "ephemeral_storage_policy_name" {
  type = string
}
# variable "ephemeral_storage_policy_id" {
#   type = string
# }
variable "default_kubernetes_service_content_library_name" {
  type = string
}
# variable "default_kubernetes_service_content_library_id" {
#   type = string
# }
# These are vSphere on Tanzu defaults, not mine
# WARNING YOU WILL LIKELY NEED TO OVERRIDE THE POD NETWORK
# AND REPLACE WITH A 172.66.0.0/16 OR SIMILAR
# (Some NSX-T and vSphere installs use 192.168, as do home networks)
variable "service_cidr_network" {
  type = string
  default = "10.96.0.0"
}
variable "service_cidr_mask" {
  type = number
  default = 12
}
variable "pod_cidr_network" {
  type = string
  default = "192.168.0.0"
}
variable "pod_cidr_mask" {
  type = number
  default = 16
}
variable "master_dns_servers" {
  type = string
}
variable "master_dns_search_domain" {
  type = string
}
variable "master_ntp_servers" {
  type = string
}
variable "master_dns_names" {
  type = string
}
variable "master_network_provider" {
  type = string
}
# TODO verify how to look this up (network-15 NOT dvportgroup-12)
variable "master_network_name" {
  type = string
}
# variable "master_network_id" {
#   type = string
# }
variable "master_network_ip_assignment_mode" {
  type = string
  default = ""
}
variable "master_network_static_gateway_ipv4" {
  type = string
}
variable "master_network_static_starting_address_ipv4" {
  type = string
}
variable "master_network_static_address_count" {
  type = number
}
variable "master_network_static_subnet_mask" {
  type = string
}

variable "data_network_static_starting_address_ipv4" {
  type = string
}
variable "data_network_static_address_count" {
  type = number
}

variable "worker_dns_servers" {
  type = string
}
variable "workload_ntp_servers" {
  type = string
}
variable "primary_workload_network_name" {
  type = string
}
variable "primary_workload_network_provider" {
  type = string
}
variable "primary_workload_network_static_gateway_ipv4" {
  type = string
}
variable "primary_workload_network_static_starting_address_ipv4" {
  type = string
}
variable "primary_workload_network_static_address_count" {
  type = number
  default = 5
}
variable "primary_workload_network_static_subnet_mask" {
  type = string
}
variable "primary_workload_network_vsphere_portgroup_name" {
  type = string
}
# variable "primary_workload_network_vsphere_portgroup_id" {
#   type = string
# }

variable "load_balancer_provider" {
  type = string
}
variable "load_balancer_avi_host" {
  type = string
}
variable "load_balancer_avi_port" {
  type = number
}
variable "load_balancer_avi_username" {
  type = string
  default = "admin"
}
variable "load_balancer_avi_password" {
  type = string
  sensitive = true
}
variable "load_balancer_avi_ca_chain" {
  type = string
}
