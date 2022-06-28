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

resource "avi_cluster" "vmware_cluster" {
  name = "cluster-0-1"
  nodes {
    ip {
      type = "V4"
      addr = var.avi_management_ip_address
    }
    name = var.avi_management_hostname
  }

}

resource "avi_backupconfiguration" "avi_backup_config" {
  name = "Backup-Configuration"
  backup_passphrase = var.avi_backup_passphrase
  save_local = true

  depends_on = [
    avi_cluster.vmware_cluster
  ]
}

# TODO determine cipher restrictions IAW UK NCSC requirements
resource "avi_systemconfiguration" "avi_system_config" {
  welcome_workflow_complete = true
  # TODO check the implications of the below two out, as they would make good defaults
  # common_criteria_mode = true
  # fips_mode = true

  # This is required else it defaults to ENTERPRISE_WITH_CLOUD_SERVICES, which fails with HTTP 500
  default_license_tier = "ENTERPRISE"

  dns_configuration {
    search_domain = var.avi_management_dns_suffix
    server_list {
      addr = var.avi_management_dns_server
      type = "V4"
    }
  }
  ntp_configuration {
    // Note the alternate config (ntp_servers) allows you to specify index numbers for each of these too
    // NOTE YOU GET HTTP 500 on Avi 21.1.4 using ntp_server_list
    # ntp_server_list {
    #   addr = var.avi_ntp_server
    #   type = "DNS"
    # }
    ntp_servers {
      key_number = 1
      server {
        addr = var.avi_ntp_server
        type = "DNS"
      }
    }
  }

  depends_on = [
    avi_backupconfiguration.avi_backup_config
  ]
}

# data "avi_cloud" "default_cloud_ref" {
#   name = "Default-Cloud"
# }

# data "avi_vrfcontext" "lookup_default_route" {
#   name = "global"

#   depends_on = [
#     avi_systemconfiguration.avi_system_config
#   ]
# }


// NOTE ALWAYS DO THIS ON THE DEFAULT CLOUD
resource "avi_vrfcontext" "avi_mgmt_context" {
  cloud_ref = "/api/cloud?name=Default-Cloud"
  name = "management"
  system_default = true
  static_routes {
    route_id = 1
    prefix {
      ip_addr {
        addr = "0.0.0.0"
        type = "V4"
      }
      mask = 0
    }
    next_hop {
      addr = var.avi_management_default_gateway
      type = "V4"
    }
  }
  depends_on = [
    avi_systemconfiguration.avi_system_config
  ]
}

// CREATE DNS PROFILE NOW
resource "avi_ipamdnsproviderprofile" "dns_profile" {
  name = "ManagementDNSProfile"
  # cloud_ref = avi_cloud.create.id # WHY???
  # TODO verify if this is supported in Essentials
  type = "IPAMDNS_TYPE_INTERNAL_DNS"
  internal_profile {
    dns_service_domain {
      domain_name = var.avi_management_domain
      pass_through = true
    }
    ttl = 30
  }
  allocate_ip_in_vrf = false

  depends_on = [
    avi_systemconfiguration.avi_system_config,
    avi_vrfcontext.avi_mgmt_context
  ]
}

# 2. Create a Cloud that can be modified and, crucially, deleted by Terraform

// Create the new cloud, but don't link until DNS set
resource "avi_cloud" "create" {
  // NOTE: DNS must be configured before the vcenter hostname can be resolved,
  //       so we create the cloud with no implementation reference then create
  //       the network, DNS profile, and IPAM profile so we can later update
  //       (WITHOUT ID - terraform weirdness) later on in vsphere_cloud.
  name = var.avi_cloud_name
  vtype = "CLOUD_NONE"
  # vtype = "CLOUD_VCENTER"
  custom_tags {
    tag_key = "vm_group_name"
    tag_val = "avi-${var.avi_deployment_name}-controller"
  }
  dhcp_enabled = false
  dns_resolvers {
    use_mgmt = true
    resolver_name = "mgmt-dns-resolver"
    nameserver_ips {
      addr = var.avi_management_dns_server
      type = "V4"
    }
  }
  # vcenter_configuration {
  #   # Note: Default gateway and static ip address pool is Via Network above and IPAM/DNS profiles
  #   datacenter = var.vm_datacenter
  #   # static IP configuration for controllers
  #   # management_ip_subnet {
  #   #   ip_addr {
  #   #     addr = var.avi_management_ip_network
  #   #     type = "V4"
  #   #   }
  #   #   mask = var.avi_management_subnet_mask_int
  #   # }
  #   # management_network = var.avi_management_network_name
  #   # management_network = avi_network.avi_management_network.id
  #   # management_network = "/api/vimgrnwruntime/?name=${avi_network.avi_management_network.name}"
  #   management_network = "/api/vimgrnwruntime/?name=${var.avi_management_network_name}"
  #   // WARNING UNLIKE ANSIBLE PROVIDER, THE AVI TERRAFORM PROVIDER
  #   // ALWAYS SEND A BLANK (AND MALFORMED) MANAGEMENT_NETWORK VALUE
  #   // UNLESS WE SPECIFY IT HERE
  #   #management_network = "https://10.220.50.10/api/network/${data.vsphere_network.mgmt_port_group.id}-${avi_cloud.create.uuid}#${var.avi_management_network_name}"
  #   // Note: MGMT NETWORK REF LOOKUP - can only be done AFTER we've connected to vSphere, so using direct name hack
  #   password = var.vcenter_password
  #   username = var.vcenter_username
  #   privilege = "WRITE_ACCESS"
  #   vcenter_url = var.vcenter_url
  # }

  depends_on = [
    avi_ipamdnsproviderprofile.dns_profile
  ]
}

# Note: If DNS Server is not on the same subnet, you need to define a default route first
# resource "avi_vrfcontext" "default_route" {
#   // HAS TO BE NAMED GLOBAL IF 0.0.0.0
#   # name = "${var.avi_cloud_name}_default_route_new"
#   name = "global"
#   # CLOUD CANNOT BE UPDATED FOR DEFAULT ROUTE
#   # cloud_ref = avi_cloud.create.id
#   # uuid = data.avi_vrfcontext.lookup_default_route.id
#   static_routes {
#     route_id = 0
#     prefix {
#       ip_addr {
#         addr = "0.0.0.0"
#         type = "V4"
#       }
#       mask = 0
#     }
#     next_hop {
#       addr = var.avi_management_default_gateway
#       type = "V4"
#     }
#   }
#   # These default to true for reasons passing understanding
#   system_default = true
#   lldp_enable = false

#   depends_on = [
#     avi_systemconfiguration.avi_system_config
#   ]
# }

// Cloud Default-Cloud resource???


# Now lookup / create full URL (Avi id) for management network
# ID is dvportgroup-15-cloud-CLOUDGUID
data "vsphere_network" "mgmt_port_group" {
  name = var.avi_management_network_name
  datacenter_id = data.vsphere_datacenter.dc.id
}


// 3. Create the IPAM profile for the vCenter Cloud network
resource "avi_ipamdnsproviderprofile" "ipam_profile" {
  name = "ManagementIPAMProfile"
  # The following is supported in Essentials and above
  type = "IPAMDNS_TYPE_INTERNAL"
  internal_profile {
    usable_networks {
      nw_ref = "https://${var.avi_management_ip_address}/api/network/${data.vsphere_network.mgmt_port_group.id}-${avi_cloud.create.uuid}#${var.avi_management_network_name}"
      # nw_ref = avi_network.avi_management_network.id
    }
    ttl = 30
  }
  depends_on = [
    # avi_network.avi_management_network,
    avi_ipamdnsproviderprofile.dns_profile
  ]
}

// 4. Now we can finally update the cloud with the vcenter connection info.
//    This also configures the management network, subnets, IPAM and DNS.
resource "avi_cloud" "vsphere_cloud" {
  // NOTE: DNS must be configured before here for the vcenter hostname to be resolved
  name = var.avi_cloud_name
  # uuid = avi_cloud.create.uuid
  vtype = "CLOUD_VCENTER"
  custom_tags {
    tag_key = "vm_group_name"
    tag_val = "avi-${var.avi_deployment_name}-controller"
  }
  dhcp_enabled = false
  ip6_autocfg_enabled = false
  dns_resolvers {
    use_mgmt = true
    resolver_name = "mgmt-dns-resolver"
    nameserver_ips {
      addr = var.avi_management_dns_server
      type = "V4"
    }
  }
  # Note: Below is useful if resolution different on mgmt and data networks
  # dns_resolution_on_se = true
  # Tanzu Docs say to leave the following as its default:-
  # enable_vip_static_routes = true
  # enable_vip_on_all_interfaces = true
  
  # TODO see if we can configure the below before the rest of the config
  # Note in the Tanzu docs we configure everything else first BUT it's not
  # clear that this is an ordering requirement, so lets test it eventually
  # ipam_provider_ref = TBD


  # mtu = 1500 or 9000

  # Note the below is recommended as true (less network interfaces on SEs)
  # BUT requires an Avi Enterprise (not essentials) license
  prefer_static_routes = var.avi_prefer_static_routes
  enable_vip_static_routes = false
  # se_group_template_ref = TBD
  # Note, only one tenant by default ("admin")
  # tenent_ref = TBD
  vcenter_configuration {
    # Note: Default gateway and static ip address pool is Via Network above and IPAM/DNS profiles
    datacenter = var.vm_datacenter
    # static IP configuration for controllers
    management_ip_subnet {
      ip_addr {
        addr = var.avi_management_ip_network
        type = "V4"
      }
      mask = var.avi_management_subnet_mask_int
      # gateway = var.avi_management_default_gateway
    }
    # management_network = var.avi_management_network_name
    # management_network = avi_network.avi_management_network.id
    # management_network = "https://10.220.50.10/api/vimgrnwruntime?name=${var.avi_management_network_name}"
    # management_network = ""
    // WARNING UNLIKE ANSIBLE PROVIDER, THE AVI TERRAFORM PROVIDER
    // ALWAYS SEND A BLANK (AND MALFORMED) MANAGEMENT_NETWORK VALUE
    // UNLESS WE SPECIFY IT HERE
    management_network = "https://${var.avi_management_ip_address}/api/network/${data.vsphere_network.mgmt_port_group.id}-${avi_cloud.create.uuid}#${var.avi_management_network_name}"
    // Note: MGMT NETWORK REF LOOKUP - can only be done AFTER we've connected to vSphere, so using direct name hack
    password = var.vcenter_password
    username = var.vcenter_username
    privilege = "WRITE_ACCESS"
    vcenter_url = var.vcenter_url
  }
  # ipam_provider_ref = avi_ipamdnsproviderprofile.ipam_profile.id
  # dns_provider_ref = avi_ipamdnsproviderprofile.dns_profile.id

  depends_on = [
    # avi_network.avi_management_network,
    avi_ipamdnsproviderprofile.ipam_profile
  ]
}

# NOTE: Unlike in the UI, terraform approach doesn't create default network sets
resource "avi_network" "avi_management_network" {
  # Management network is the vm_network for the controller - same name
  name = var.avi_management_network_name
  cloud_ref = avi_cloud.create.id
  # cloud_ref = avi_cloud.vsphere_cloud.id
  # vimgrnw_ref = "https://10.220.50.10/api/network/${data.vsphere_network.mgmt_port_group.id}-${avi_cloud.create.uuid}#${var.avi_management_network_name}"
  vcenter_dvs = true
  
  dhcp_enabled = "false"
  ip6_autocfg_enabled = false
  configured_subnets {
    prefix {
      ip_addr {
        addr = var.avi_management_ip_network
        type = "V4"
      }
      mask = var.avi_management_subnet_mask_int
    }
    static_ip_ranges {
      range {
        begin {
          addr = var.avi_management_ip_address_start
          type = "V4"
        }
        end {
          addr = var.avi_management_ip_address_end
          type = "V4"
        }
      }
      type = "STATIC_IPS_FOR_VIP_AND_SE"
    }
    # gateway = var.avi_management_default_gateway
  }

  depends_on = [
    avi_cloud.vsphere_cloud
  ]
}

# THIS IS IDENTICAL BUT FORCES THE VIMGRNWRUNTIME LINK TO BE ADDED
# resource "avi_network" "avi_management_network_reconfigure" {
#   # Management network is the vm_network for the controller - same name
#   name = var.avi_management_network_name
#   cloud_ref = avi_cloud.vsphere_cloud.id
#   id = avi_network.avi_management_network.id
#   # cloud_ref = avi_cloud.vsphere_cloud.id
#   dhcp_enabled = "false"
#   ip6_autocfg_enabled = false
#   configured_subnets {
#     prefix {
#       ip_addr {
#         addr = var.avi_management_ip_network
#         type = "V4"
#       }
#       mask = var.avi_management_subnet_mask_int
#     }
#     static_ip_ranges {
#       range {
#         begin {
#           addr = var.avi_management_ip_address_start
#           type = "V4"
#         }
#         end {
#           addr = var.avi_management_ip_address_end
#           type = "V4"
#         }
#       }
#       type = "STATIC_IPS_FOR_VIP_AND_SE"
#     }
#   }

#   depends_on = [
#     avi_cloud.vsphere_cloud
#   ]
# }

resource "avi_vrfcontext" "avi_data_context" {
  # Sets default route for the "Data Network" (aka "VIP Network" in old docs)
  cloud_ref = avi_cloud.vsphere_cloud.id
  name = "global"
  system_default = true
  static_routes {
    route_id = 0
    prefix {
      ip_addr {
        addr = "0.0.0.0"
        type = "V4"
      }
      mask = 0
    }
    next_hop {
      addr = var.avi_data_network_default_gateway
      type = "V4"
    }
  }
  
  depends_on = [
    avi_cloud.vsphere_cloud
  ]
}



// NOTE ALWAYS DO THIS ON THE DEFAULT CLOUD
resource "avi_vrfcontext" "avi_mgmt_context_new_cloud" {
  cloud_ref = avi_cloud.vsphere_cloud.id
  name = "management"
  system_default = true
  static_routes {
    route_id = 1
    prefix {
      ip_addr {
        addr = "0.0.0.0"
        type = "V4"
      }
      mask = 0
    }
    next_hop {
      addr = var.avi_management_default_gateway
      type = "V4"
    }
  }
  depends_on = [
    avi_vrfcontext.avi_data_context,
    avi_cloud.vsphere_cloud
  ]
}

// IPAM FOR DATA NETWORK
resource "avi_ipamdnsproviderprofile" "ipam_data_profile" {
  name = "DataIPAMProfile"
  # The following is supported in Essentials and above
  type = "IPAMDNS_TYPE_INTERNAL"
  internal_profile {
    usable_networks {
      # nw_ref = "https://10.220.50.10/api/network/${data.vsphere_network.mgmt_port_group.id}-${avi_cloud.create.uuid}#${var.avi_management_network_name}"
      nw_ref = "https://${var.avi_management_ip_address}/api/network?name=${var.avi_data_network_name}"
    }
    ttl = 30
  }

  depends_on = [
    avi_vrfcontext.avi_data_context,
    avi_vrfcontext.avi_mgmt_context_new_cloud
  ]
}

resource "avi_network" "avi_data_network" {
  # Data network is network the Avi SEs run on, and VIPs created on
  name = var.avi_data_network_name
  # cloud_ref = avi_cloud.vsphere_cloud.id
  cloud_ref = avi_cloud.create.id
  # cloud_ref = var.avi_cloud_name
  ip6_autocfg_enabled = false
  dhcp_enabled = "false"
  // Note: No default gateway. Configured in SE group config???
  configured_subnets {
    prefix {
      ip_addr {
        addr = var.avi_data_network_network_ipv4
        type = "V4"
      }
      mask = var.avi_data_network_subnet_mask_int
    }
    static_ip_ranges {
      range {
        begin {
          addr = var.avi_data_network_start_ipv4
          type = "V4"
        }
        end {
          addr = var.avi_data_network_end_ipv4
          type = "V4"
        }
      }
      type = "STATIC_IPS_FOR_VIP_AND_SE"
    }
  }
  
  depends_on = [
    avi_ipamdnsproviderprofile.ipam_data_profile
  ]
}

resource "avi_serviceenginegroup" "default_group" {
  # name = "Default-Group"
  name = var.avi_se_group_name
  cloud_ref = avi_cloud.vsphere_cloud.id

  ha_mode = "HA_MODE_SHARED" # means N+M (Enterprise license required)
  se_name_prefix = "Avi" # results in Avi-se-abcde
  # TODO can we specify a resource group as well as a folder? (like for controllers) (Not currently, it would appear, we'll have to move them after creation)
  vcenter_folder = "AviSeFolder"
  vcenter_clusters {
    include = true
    cluster_refs = [
      "https://${var.avi_management_ip_address}/api/vimgrclusterruntime?name=${var.vm_cluster}"
    ]
  }

# HOSTS NOT REQUIRED, ONLY CLUSTER
#   vcenter_hosts {
#     include = true
#     host_refs = [
#       # "https://10.220.50.10/api/vimgrhostruntime/host-14-cloud-c74473a8-f12a-4ece-854f-a2f16c0667b1#esxi01.h2o-4-328.h2o.vmware.com"
#       "https://10.220.50.10/api/vimgrclusterruntime/${data.vsphere_host.esxi01.id}#${var.esxi_vm_name}"
#       # TODO support multiple ESXi hosts per cluster
#     ]
#   }

#   data_network_id = avi_network.avi_data_network.id
#   mgmt_network_ref = avi_network.avi_management_network.id
  # TODO placement_across_ses changed to distributed by default
  min_se = 1
  max_se = 7
  buffer_se = 1
  # hypervisor = ""
  max_vs_per_se = 100
  min_scaleout_per_vs = 1
  max_scaleout_per_vs = 4
  # TODO check if the below results in VM attributes (useful for vm-vm anti-affinity rules later) -> Can't, need to use VM names(IDs) only
  # labels = ""
  # custom_tag = []

  depends_on = [
    avi_network.avi_management_network,
    avi_network.avi_data_network
  ]
}

// 5. Now we can finally update the cloud with the default SE template.
//    This has to be done AFTER the data and management networks are 
//    finally configured.
resource "avi_cloud" "vsphere_cloud_with_se" {
  // NOTE: DNS must be configured before here for the vcenter hostname to be resolved
  name = var.avi_cloud_name
  # uuid = avi_cloud.create.uuid
  vtype = "CLOUD_VCENTER"
  custom_tags {
    tag_key = "vm_group_name"
    tag_val = "avi-${var.avi_deployment_name}-controller"
  }
  dhcp_enabled = false
  ip6_autocfg_enabled = false
  dns_resolvers {
    use_mgmt = true
    resolver_name = "mgmt-dns-resolver"
    nameserver_ips {
      addr = var.avi_management_dns_server
      type = "V4"
    }
  }
  # Note: Below is useful if resolution different on mgmt and data networks
  # dns_resolution_on_se = true
  # Tanzu Docs say to leave the following as its default:-
  # enable_vip_static_routes = true
  # enable_vip_on_all_interfaces = true
  
  # TODO see if we can configure the below before the rest of the config
  # Note in the Tanzu docs we configure everything else first BUT it's not
  # clear that this is an ordering requirement, so lets test it eventually
  # ipam_provider_ref = TBD


  # mtu = 1500 or 9000

  # Note the below is recommended as true (less network interfaces on SEs)
  # BUT requires an Avi Enterprise (not essentials) license
  prefer_static_routes = var.avi_prefer_static_routes
  enable_vip_static_routes = false
  # se_group_template_ref = TBD
  # Note, only one tenant by default ("admin")
  # tenent_ref = TBD
  vcenter_configuration {
    # Note: Default gateway and static ip address pool is Via Network above and IPAM/DNS profiles
    datacenter = var.vm_datacenter
    # static IP configuration for controllers
    management_ip_subnet {
      ip_addr {
        addr = var.avi_management_ip_network
        type = "V4"
      }
      mask = var.avi_management_subnet_mask_int
    }
    # management_network = var.avi_management_network_name
    # management_network = avi_network.avi_management_network.id
    # management_network = "https://10.220.50.10/api/vimgrnwruntime?name=${var.avi_management_network_name}"
    # management_network = ""
    // WARNING UNLIKE ANSIBLE PROVIDER, THE AVI TERRAFORM PROVIDER
    // ALWAYS SEND A BLANK (AND MALFORMED) MANAGEMENT_NETWORK VALUE
    // UNLESS WE SPECIFY IT HERE
    management_network = "https://${var.avi_management_ip_address}/api/network/${data.vsphere_network.mgmt_port_group.id}-${avi_cloud.create.uuid}#${var.avi_management_network_name}"
    // Note: MGMT NETWORK REF LOOKUP - can only be done AFTER we've connected to vSphere, so using direct name hack
    password = var.vcenter_password
    username = var.vcenter_username
    privilege = "WRITE_ACCESS"
    vcenter_url = var.vcenter_url

  }
  // NOTE WE'VE NOW SWITCHED TO THE DATA IPAM
  ipam_provider_ref = avi_ipamdnsproviderprofile.ipam_data_profile.id
  # ipam_provider_ref = avi_ipamdnsproviderprofile.ipam_profile.id
  # dns_provider_ref = avi_ipamdnsproviderprofile.dns_profile.id

  // NOTE WE'VE ALSO NOW SPECIFIED THE SE GROUP TEMPLATE TO USE
  # se_group_template_ref = avi_serviceenginegroup.default_group.id

  depends_on = [
    # avi_network.avi_management_network,
    avi_serviceenginegroup.default_group
  ]
}

# TODO vm-vm host anti-affinity groups for Avi-SE VMs

# TODO just output the VIP name, the rest were from known config

# Read raw cert if it already exists
data "avi_sslkeyandcertificate" "loadcertifexists" {
  name = "NewControllerCert"
  depends_on = [
    avi_cloud.vsphere_cloud_with_se
  ]
}

# Generate a new certificate and download
resource "avi_sslkeyandcertificate" "cert" {
  certificate {
    expiry_status = "SSL_CERTIFICATE_GOOD"
    days_until_expire = 365
    self_signed = true
    subject {
      common_name = var.avi_management_ip_address
    }
    subject_alt_names = [
      var.avi_management_ip_address,
      "avi.${var.avi_management_domain}"
    ]
    // Hack for Avi provider bug - certificate value required even for generate not upload
    certificate = (null != data.avi_sslkeyandcertificate.loadcertifexists.certificate ? "${one(data.avi_sslkeyandcertificate.loadcertifexists.certificate[*]).certificate}" : "")
  }
  status = "SSL_CERTIFICATE_FINISHED"
  format = "SSL_PEM"
  key_params {
    algorithm = "SSL_KEY_ALGORITHM_EC"
    ec_params {
      curve = "SSL_KEY_EC_CURVE_SECP256R1"
    }
  }
  certificate_base64 = true
  key_base64 = true
  enable_ocsp_stapling = false
  ocsp_config {
    ocsp_req_interval = 86400
    url_action = "OCSP_RESPONDER_URL_FAILOVER"
    failed_ocsp_jobs_retry_interval = 3600
    max_tries = 10
  }
  type = "SSL_CERTIFICATE_TYPE_SYSTEM"
  name = "NewControllerCert"

  depends_on = [
    # avi_serviceenginegroup.default_group
    data.avi_sslkeyandcertificate.loadcertifexists
  ]
}

# Now load the certificate to fetch the full details for ca chain
data "avi_sslkeyandcertificate" "loadcert" {
  name = avi_sslkeyandcertificate.cert.name
}
# Assuming a single level of indirection...
data "avi_sslkeyandcertificate" "loadrootcert" {
  // TODO make this dynamic... somehow... 
  # name = data.avi_sslkeyandcertificate.loadcert.ca_certs[0].name
  name = "System-Default-Root-CA"

  depends_on = [
    data.avi_sslkeyandcertificate.loadcert
  ]
}

# Now attach the cert to the portal

resource "avi_systemconfiguration" "avi_system_final_config" {
  welcome_workflow_complete = true
  # TODO check the implications of the below two out, as they would make good defaults
  # common_criteria_mode = true
  # fips_mode = true

  # This is required else it defaults to ENTERPRISE_WITH_CLOUD_SERVICES, which fails with HTTP 500
  default_license_tier = "ENTERPRISE"

  dns_configuration {
    search_domain = var.avi_management_dns_suffix
    server_list {
      addr = var.avi_management_dns_server
      type = "V4"
    }
  }
  ntp_configuration {
    // Note the alternate config (ntp_servers) allows you to specify index numbers for each of these too
    // NOTE YOU GET HTTP 500 on Avi 21.1.4 using ntp_server_list
    # ntp_server_list {
    #   addr = var.avi_ntp_server
    #   type = "DNS"
    # }
    ntp_servers {
      key_number = 1
      server {
        addr = var.avi_ntp_server
        type = "DNS"
      }
    }
  }
  portal_configuration {
    sslkeyandcertificate_refs = [
      data.avi_sslkeyandcertificate.loadcert.id
    ]
  }

  depends_on = [
    data.avi_sslkeyandcertificate.loadrootcert,
    data.avi_sslkeyandcertificate.loadcert
  ]
}

output "system_configuration" {
  value = avi_systemconfiguration.avi_system_final_config
}

output "cloud" {
  value = avi_cloud.vsphere_cloud_with_se
  sensitive = true
}

output "data_network" {
  value = avi_network.avi_data_network
}

output "management_network" {
  value = avi_network.avi_management_network
}

output "cert" {
  value = one(data.avi_sslkeyandcertificate.loadcert.certificate[*])
}

output "rootcert" {
  value = one(data.avi_sslkeyandcertificate.loadrootcert.certificate[*])
}

# output "cachain" {
#   value = "${data.avi_sslkeyandcertificate.loadcert.certificate.1.certificate}\n${data.avi_sslkeyandcertificate.loadrootcert.certificate.1.certificate}"
# }