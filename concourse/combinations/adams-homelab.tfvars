
# General settings

# A general deployment name for tagging or unique reference purposes
deployment_name = "lab01"

# vSphere settings

vsphere_hostname = "vcenter01.lab01.my.cloud"
vsphere_username = "Administrator@lab01.my.cloud"
# vsphere_password = ""
vsphere_insecure = true

vsphere_datacenter = "lab01.my.cloud"
vsphere_cluster = "Cluster01"
vsphere_vm_datastore = "lab01"
vsphere_vm_folder = ""

esxi_vm_name = "vesxi01.lab01.my.cloud"

# General network settings

management_network_name = "VM Network"
management_dns_server = "10.2.0.1"
management_ntp_server1 = "10.2.0.1"
management_domain = "lab01.my.cloud"
// MUST NOT OVERLAP WITH TANZU SUPERVISOR CLUSTER IP RANGE
management_start_ipv4 = "10.2.0.55"
management_end_ipv4 = "10.2.0.64"
management_network_ipv4 = "10.2.0.0"
management_subnet_mask_int = 24
management_subnet_mask_long = "255.255.255.0"
management_default_gateway = "10.2.0.1"


data_network_name = "Avi Data Network"
// Data DNS server?
data_network_start_ipv4 = "172.16.6.16"
data_network_end_ipv4 = "172.16.6.254"
data_network_address_count = 239
// Note leaving .40-.61 for Tanzu Workload Network IPs...
// This is because h2o only gives us one routable workload network!!!
data_network_ipv4 = "172.16.6.0"
data_network_subnet_mask_int = 24
data_network_default_gateway = "172.16.6.1"

workload_network_name = "K8S Workload01 Network"
# Must be a DNS-1123 compliant name
# workload_network_name = "k8s-workload01-network"
workload_dns_server = "172.16.7.1"
workload_ntp_server1 = "172.16.7.1"
workload_start_ipv4 = "172.16.7.16"
workload_address_count = 239
# workload_network_end_ipv4 = "10.220.50.61"
workload_subnet_mask_int = 24
workload_subnet_mask_long = "255.255.255.0"
workload_network_ipv4 = "172.16.7.0"
workload_default_gateway = "172.16.7.1"


# AVI settings

# Avi Server version number to be deployed (E.g. from controller OVA filename)
avi_version = "21.1.2"
# Leave this as admin for now!!! Not tested with other values.
# avi_tenant     = "admin"

# Manually created for Avi before install:-
avi_content_library = "VMDefaultContentLibrary"
avi_vm_template = "controller-21.1.2-9124" // no .ova

# The rest we create for the user
# avi_vm_resource_pool = "AVI_CTRL"
avi_vm_name = "avi-controller" // patterned for -1, -2 etc.

// Specified here because we've not created Avi yet
avi_username = "admin"
# avi_password = ""

avi_cloud_name = "Default-Cloud"
avi_se_group_name = "Default-Group"

// template customisation
avi_management_hostname = "avi-controller-1"
// TODO support multiple controller instances
avi_management_address_ipv4 = "10.2.0.48"
# avi_management_port = 443

# avi_cloud_name = "VSphere-Cloud"

// Make this different from the admin password...
# avi_backup_passphrase = ""



# Tanzu settings here

tanzu_image_storage_policy_name = "K8S Storage Policy"
tanzu_supervisor_storage_policy_name = "K8S Storage Policy"
tanzu_ephemeral_storage_policy_name = "K8S Storage Policy"
tanzu_default_kubernetes_service_content_library_name = "TanzuDefaultContentLibrary"

tanzu_supervisor_dns_names = "tanzu.lab01.my.cloud"
// MUST NOT OVERLAP WITH MANAGEMENT IP RANGE (USED BY AVI SE VMs)
tanzu_supervisor_start_ipv4 = "10.2.0.50"
# tanzu_supervisor_address_count = 5
