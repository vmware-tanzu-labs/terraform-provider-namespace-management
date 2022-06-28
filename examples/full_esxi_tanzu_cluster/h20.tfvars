
# General settings

# A general deployment name for tagging or unique reference purposes
deployment_name = "h2o"

# vSphere settings

vsphere_hostname = "vc01.h2o-4-328.h2o.vmware.com"
vsphere_username = "Administrator@vsphere.local"
vsphere_password = ""
vsphere_insecure = true

vsphere_datacenter = "vc01"
vsphere_cluster = "vc01cl01"
vsphere_vm_datastore = "vsanDatastore"
vsphere_vm_folder = ""

esxi_vm_name = "esxi01.h2o-4-328.h2o.vmware.com"

# General network settings

management_network_name = "esxi-mgmt"
management_dns_server = "10.79.2.5"
management_ntp_server1 = "time1.oc.vmware.com"
management_domain = "h2o-4-328.h2o.vmware.com"
management_start_ipv4 = "10.220.50.13"
management_end_ipv4 = "10.220.50.19"
management_network_ipv4 = "10.220.50.0"
management_subnet_mask_int = 27
management_subnet_mask_long = "255.255.255.224"
management_default_gateway = "10.220.50.30"


data_network_name = "user-workload"
// Data DNS server?
data_network_start_ipv4 = "10.220.50.33"
data_network_end_ipv4 = "10.220.50.39"
data_network_address_count = 7
// Note leaving .40-.61 for Tanzu Workload Network IPs...
// This is because h2o only gives us one routable workload network!!!
data_network_ipv4 = "10.220.50.32"
data_network_subnet_mask_int = 27
data_network_default_gateway = "10.220.50.62"

workload_network_name = "user-workload"
workload_dns_server = "10.79.2.5"
workload_ntp_server1 = "time1.oc.vmware.com"
workload_start_ipv4 = "10.220.50.40"
workload_address_count = 20
# workload_network_end_ipv4 = "10.220.50.61"
workload_subnet_mask_int = 27
workload_subnet_mask_long = "255.255.255.224"
workload_network_ipv4 = "10.220.50.32"
workload_default_gateway = "10.220.50.62"


# AVI settings

# Avi Server version number to be deployed (E.g. from controller OVA filename)
avi_version = "21.1.2"
# Leave this as admin for now!!! Not tested with other values.
# avi_tenant     = "admin"

# Manually created for Avi before install:-
avi_content_library = "DefaultContentLibrary"
avi_vm_template = "controller-21.1.2-9124" // no .ova

# The rest we create for the user
# avi_vm_resource_pool = "AVI_CTRL"
avi_vm_name = "avi-controller" // patterned for -1, -2 etc.

// Specified here because we've not created Avi yet
avi_username = "admin"
# avi_password = ""

// template customisation
avi_management_hostname = "avi-controller-01"
// TODO support multiple controller instances
avi_management_address_ipv4 = "10.220.50.10"
# avi_management_port = 443

# avi_cloud_name = "VSphere-Cloud"

// Make this different from the admin password...
# avi_backup_passphrase = ""



# Tanzu settings here

tanzu_image_storage_policy_name = "K8sDefaultStoragePolicy"
tanzu_supervisor_storage_policy_name = "K8sDefaultStoragePolicy"
tanzu_ephemeral_storage_policy_name = "K8sDefaultStoragePolicy"
tanzu_default_kubernetes_service_content_library_name = "tanzu-content-library"

tanzu_supervisor_dns_names = "tanzu.h2o-4-328.h2o.vmware.com"
tanzu_supervisor_start_ipv4 = "10.220.50.20"
# tanzu_supervisor_address_count = 5
