terraform {
  required_providers {
    // Force local binary use, rather than public binary
    namespace-management = {
      version = ">= 0.1"
      source  = "vmware.com/vcenter/namespace-management"
      # Use this for your user terraform scripts (above is for our devs only)
      # source  = "vmware/namespace-management"
    }
    vsphere = {
      version = ">= 2.1.1"
      source = "hashicorp/vsphere"
    }
  }
}

data "vsphere_datacenter" "dc" {
  name = var.datacenter_name
}

# Converts the vSphere cluster name to its id
data "vsphere_compute_cluster" "fetch" {
  name = var.cluster_name
  datacenter_id = data.vsphere_datacenter.dc.id
}
# ALTERNATIVE to the above, but cannot use as SC may not exist yet:-
# data "namespace-management_cluster" "fetch" {
#   name = var.cluster_name
#   # Note: No need for datacenter_id in this API
# }

data "vsphere_network" "mgmt_net" {
  name = var.master_network_name
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_storage_policy" "image_policy" {
  name = var.image_storage_policy_name
}
data "vsphere_storage_policy" "master_policy" {
  name = var.master_storage_policy_name
}
data "vsphere_storage_policy" "ephemeral_policy" {
  name = var.ephemeral_storage_policy_name
}

data "vsphere_content_library" "default_k8s_library" {
  name = var.default_kubernetes_service_content_library_name
}

data "vsphere_network" "workload_pg" {
  datacenter_id = data.vsphere_datacenter.dc.id
  # type = "DISTRIBUTED_PORTGROUP"
  name = var.primary_workload_network_vsphere_portgroup_name
}

# Enables the Tanzu Supervisor Cluster
resource "namespace-management_cluster" "supervisor" {
  // No ID specified! Let the READ operation lookup via id in terraform

  cluster_id = data.vsphere_compute_cluster.fetch.id
  image_storage_policy_id = data.vsphere_storage_policy.image_policy.id
  master_storage_policy_id = data.vsphere_storage_policy.master_policy.id
  ephemeral_storage_policy_id = data.vsphere_storage_policy.ephemeral_policy.id
  default_kubernetes_service_content_library_id = data.vsphere_content_library.default_k8s_library.id
  service_cidr_network = var.service_cidr_network
  service_cidr_mask = var.service_cidr_mask
  master_dns_servers = var.master_dns_servers
  master_dns_search_domain = var.master_dns_search_domain
  master_ntp_servers = var.master_ntp_servers
  master_dns_names = var.master_dns_names
  master_network_provider = var.master_network_provider
  master_network_id = data.vsphere_network.mgmt_net.id
  // Since 7.0u3:-
  # master_network_ip_assignment_mode = var.master_network_ip_assignment_mode
  master_network_static_gateway_ipv4 = var.master_network_static_gateway_ipv4
  master_network_static_starting_address_ipv4 = var.master_network_static_starting_address_ipv4
  master_network_static_address_count = var.master_network_static_address_count
  master_network_static_subnet_mask = var.master_network_static_subnet_mask

  data_network_static_starting_address_ipv4 = var.data_network_static_starting_address_ipv4
  data_network_static_address_count = var.data_network_static_address_count

  worker_dns_servers = var.worker_dns_servers
  workload_ntp_servers = var.workload_ntp_servers
  primary_workload_network_name = data.vsphere_network.workload_pg.id
  primary_workload_network_provider = var.primary_workload_network_provider
  primary_workload_network_static_gateway_ipv4 = var.primary_workload_network_static_gateway_ipv4
  primary_workload_network_static_starting_address_ipv4 = var.primary_workload_network_static_starting_address_ipv4
  primary_workload_network_static_address_count = var.primary_workload_network_static_address_count
  primary_workload_network_static_subnet_mask = var.primary_workload_network_static_subnet_mask
  primary_workload_network_vsphere_portgroup_id = data.vsphere_network.workload_pg.id
  load_balancer_provider = var.load_balancer_provider
  load_balancer_avi_host = var.load_balancer_avi_host
  load_balancer_avi_port = var.load_balancer_avi_port
  load_balancer_avi_username = var.load_balancer_avi_username
  load_balancer_avi_password = var.load_balancer_avi_password
  load_balancer_avi_ca_chain = var.load_balancer_avi_ca_chain
}

# Only the newly enabled cluster (including the cluster ID)
output "cluster" {
  value = namespace-management_cluster.supervisor
}

# Convenience output for future commands
output "datacenter_id" {
  value = data.vsphere_datacenter.dc.id
}
