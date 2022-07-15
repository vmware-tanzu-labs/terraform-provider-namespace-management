//  Copyright 2022 VMware, Inc.
//  SPDX-License-Identifier: Apache-2.0
//

package namespace_management

import (
	"context"

	"github.com/hashicorp/terraform-plugin-sdk/v2/diag"
	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/schema"

	"github.com/vmware/govmomi/vapi/namespace"
)

func resourceCluster() *schema.Resource {
	return &schema.Resource{
		CreateContext: resourceClusterCreate,
		ReadContext:   resourceClusterRead,
		UpdateContext: resourceClusterUpdate,
		DeleteContext: resourceClusterDelete,
		Schema: map[string]*schema.Schema{
			// Note this is the equivalent of ClusterSummary
			// See https://github.com/vmware/govmomi/blob/4a6c4b155da486e3f9058aac9dfc10a8f364c6ce/vapi/namespace/namespace.go#L116
			// The TERRAFORM ID for this element. Same as the cluster_id in vSphere.
			"id": {
				Type:     schema.TypeString,
				Computed: true,
				Optional: true,
			},
			// The vSphere cluster_id to enable workload management for (use ID for read)
			"cluster_id": {
				Type:     schema.TypeString,
				Required: true,
			},
			// Textual name for the vSphere cluster (returned from the API)
			"cluster_name": {
				Type:     schema.TypeString,
				Computed: true,
			},
			"kubernetes_status": {
				Type:     schema.TypeString,
				Computed: true,
			},
			"config_status": {
				Type:     schema.TypeString,
				Computed: true,
			},
			// TODO add all ENABLING and detail fields here for supervisor cluster (NOT just the summary as in the data call equivalent)
			"image_storage_policy_id": {
				Type:     schema.TypeString,
				Optional: true,
			},
			"master_storage_policy_id": {
				Type:     schema.TypeString,
				Optional: true,
			},
			"ephemeral_storage_policy_id": {
				Type:     schema.TypeString,
				Optional: true,
			},
			"default_kubernetes_service_content_library_id": {
				Type:     schema.TypeString,
				Optional: true,
			},
			// Internal K8S service network
			"service_cidr_network": {
				Type:     schema.TypeString,
				Optional: true,
				Default:  "10.96.0.0",
			},
			"service_cidr_mask": {
				Type:     schema.TypeInt,
				Optional: true,
				Default:  23,
			},

			// K8S supervisor Networking
			"master_dns_servers": {
				Type:     schema.TypeString,
				Optional: true,
			},
			"master_dns_search_domain": {
				Type:     schema.TypeString,
				Optional: true,
			},
			"master_ntp_servers": {
				Type:     schema.TypeString,
				Optional: true,
			},
			// E.g. tanzu.SEARCH_DOMAIN (full, for certs)
			"master_dns_names": {
				Type:     schema.TypeString,
				Optional: true,
			},
			"master_network_provider": {
				Type:     schema.TypeString,
				Optional: true,
				Default:  "VSPHERE_NETWORK",
			},
			// E.g. network-15
			"master_network_id": {
				Type:     schema.TypeString,
				Optional: true,
			},
			"master_network_ip_assignment_mode": {
				Type:     schema.TypeString,
				Optional: true,
				Default:  "STATICRANGE", // OR DHCP
			},
			"master_network_static_gateway_ipv4": {
				Type:     schema.TypeString,
				Optional: true,
			},
			"master_network_static_starting_address_ipv4": {
				Type:     schema.TypeString,
				Optional: true,
			},
			"master_network_static_address_count": {
				Type:     schema.TypeInt,
				Optional: true,
			},
			// E.g. 255.255.255.0
			"master_network_static_subnet_mask": {
				Type:     schema.TypeString,
				Optional: true,
			},
			// E.g. dvportgroup-15 - NOT USED - uses master_network_id (not pg) instead
			// "master_network_vsphere_portgroup_id": {
			// 	Type:     schema.TypeString,
			// 	Optional: true,
			// },
			// TODO NSX-T settings for master network

			"data_network_static_starting_address_ipv4": {
				Type:     schema.TypeString,
				Optional: true,
			},
			"data_network_static_address_count": {
				Type:     schema.TypeInt,
				Optional: true,
			},

			// K8S Workload Networking
			// worker_dns Name is historical from Rest API
			"worker_dns_servers": {
				Type:     schema.TypeString,
				Optional: true,
			},
			"workload_ntp_servers": {
				Type:     schema.TypeString,
				Optional: true,
			},
			// E.g. k8s-workload-network (MUST be a DNS compliant name)
			"primary_workload_network_name": {
				Type:     schema.TypeString,
				Optional: true,
			},
			"primary_workload_network_provider": {
				Type:     schema.TypeString,
				Optional: true,
				Default:  "VSPHERE_NETWORK",
			},
			"primary_workload_network_static_gateway_ipv4": {
				Type:     schema.TypeString,
				Optional: true,
			},
			"primary_workload_network_static_starting_address_ipv4": {
				Type:     schema.TypeString,
				Optional: true,
			},
			"primary_workload_network_static_address_count": {
				Type:     schema.TypeInt,
				Optional: true,
			},
			// E.g. 255.255.255.0
			"primary_workload_network_static_subnet_mask": {
				Type:     schema.TypeString,
				Optional: true,
			},
			// E.g. dvportgroup-15
			"primary_workload_network_vsphere_portgroup_id": {
				Type:     schema.TypeString,
				Optional: true,
			},
			// TODO NSX-T settings for workload network

			// TODO other LB types for Tanzu (E.g. NSX-T)
			"load_balancer_provider": {
				Type:     schema.TypeString,
				Optional: true,
				Default:  "AVI",
			},
			// Network resolvable name for the load balancer (not used for network routing!!!)
			"load_balancer_id": {
				Type:     schema.TypeString,
				Optional: true,
				Default:  "avi-lb",
			},
			"load_balancer_avi_host": {
				Type:     schema.TypeString,
				Optional: true,
			},
			"load_balancer_avi_port": {
				Type:     schema.TypeInt,
				Optional: true,
				Default:  443,
			},
			"load_balancer_avi_username": {
				Type:     schema.TypeString,
				Optional: true,
			},
			"load_balancer_avi_password": {
				Type:      schema.TypeString,
				Optional:  true,
				Sensitive: true,
			},
			"load_balancer_avi_ca_chain": {
				Type:     schema.TypeString,
				Optional: true,
			},
		},
	}
}

func resourceClusterCreate(ctx context.Context, d *schema.ResourceData, m interface{}) diag.Diagnostics {
	// Warning or errors can be collected in a slice type
	var diags diag.Diagnostics
	ns := m.(*namespace.Manager)

	clusterId := d.Get("cluster_id").(string)
	// clusterName := d.Get("name").(string)
	imagePolicyId := d.Get("image_storage_policy_id").(string)
	masterPolicyId := d.Get("master_storage_policy_id").(string)
	ephemeralPolicyId := d.Get("ephemeral_storage_policy_id").(string)
	defaultLibraryId := d.Get("default_kubernetes_service_content_library_id").(string)
	serviceCidrNetwork := d.Get("service_cidr_network").(string)
	serviceCidrMask := d.Get("service_cidr_mask").(int)

	masterDnsServers := d.Get("master_dns_servers").(string)
	masterDnsSearchDomains := d.Get("master_dns_search_domain").(string)
	masterDnsNames := d.Get("master_dns_names").(string)
	masterNtpServers := d.Get("master_ntp_servers").(string)
	masterNetworkId := d.Get("master_network_id").(string)
	masterNetworkProvider := d.Get("master_network_provider").(string)

	masterNetworkStartingAddressIpv4 := d.Get("master_network_static_starting_address_ipv4").(string)
	masterNetworkAddressCount := d.Get("master_network_static_address_count").(int)
	if "" == masterNetworkStartingAddressIpv4 || 0 == masterNetworkAddressCount {
		diags = append(diags, diag.Diagnostic{
			Severity: diag.Error,
			Summary:  "Supervisor starting address or address count was empty",
		})
		return diags
	}
	masterNetworkSubnetMask := d.Get("master_network_static_subnet_mask").(string)
	masterNetworkGateway := d.Get("master_network_static_gateway_ipv4").(string)
	// masterNetworkPortgroup := d.Get("master_network_vsphere_portgroup_id").(string)

	workloadDnsServers := d.Get("worker_dns_servers").(string)
	workloadNtpServers := d.Get("workload_ntp_servers").(string)
	workloadNetworkName := d.Get("primary_workload_network_name").(string)
	workloadNetworkProvider := d.Get("primary_workload_network_provider").(string)
	workloadNetworkStartingAddressIpv4 := d.Get("primary_workload_network_static_starting_address_ipv4").(string)
	workloadNetworkAddressCount := d.Get("primary_workload_network_static_address_count").(int)
	if "" == workloadNetworkStartingAddressIpv4 || 0 == workloadNetworkAddressCount {
		diags = append(diags, diag.Diagnostic{
			Severity: diag.Error,
			Summary:  "Workload starting address or address count was empty",
		})
		return diags
	}
	workloadNetworkSubnetMask := d.Get("primary_workload_network_static_subnet_mask").(string)
	workloadNetworkGateway := d.Get("primary_workload_network_static_gateway_ipv4").(string)
	workloadNetworkPortgroup := d.Get("primary_workload_network_vsphere_portgroup_id").(string)

	dataNetworkStartingAddressIpv4 := d.Get("data_network_static_starting_address_ipv4").(string)
	dataNetworkAddressCount := d.Get("data_network_static_address_count").(int)

	lbType := d.Get("load_balancer_provider").(string)
	lbId := d.Get("load_balancer_id").(string)
	lbAviControllerHost := d.Get("load_balancer_avi_host").(string)
	lbAviControllerPort := d.Get("load_balancer_avi_port").(int)
	lbAviCaChain := d.Get("load_balancer_avi_ca_chain").(string)
	lbAviUsername := d.Get("load_balancer_avi_username").(string)
	lbAviPassword := d.Get("load_balancer_avi_password").(string)

	// Now object conversion before operation
	masterNetworkProviderObj := namespace.ClusterNetworkProviderFromString(masterNetworkProvider)
	workloadNetworkProviderObj := namespace.ClusterNetworkProviderFromString(workloadNetworkProvider)
	lbTypeObj := namespace.LoadBalancerFromString(lbType)

	// Note: Passing in an empty slive WITHOUT omitempty gives an empty json array []
	var ranges []namespace.IpRange
	// Empty array in JSON if Avi (Avi assigns IPs in its config)
	// if namespace.AviLoadBalancerProvider != lbTypeObj {

	// This is actually management network range, and never specified via the GUI, so leaving blank here
	ranges = []namespace.IpRange{{
		Address: dataNetworkStartingAddressIpv4,
		Count:   dataNetworkAddressCount,
	}}
	// }

	// Hard code a viable cluster for now
	spec := &namespace.EnableClusterSpec{
		ImageStorage: namespace.ImageStorageSpec{
			StoragePolicy: imagePolicyId, // GUID on submission
		},
		MasterNTPServers:       []string{masterNtpServers},
		DefaultImageRepository: "",                // blank
		EphemeralStoragePolicy: ephemeralPolicyId, // GUID on submission
		ServiceCidr: &namespace.Cidr{
			Address: serviceCidrNetwork,
			Prefix:  serviceCidrMask,
		},
		SizeHint: &namespace.SmallSizingHint,
		// TODO SPECIFY DEFAULT IMAGE REGISTRY (OPTIONAL)
		// DefaultImageRegistry = ns.DefaultImageRegistry{}
		WorkerDNS:              []string{workloadDnsServers},
		MasterDNS:              []string{masterDnsServers},
		NetworkProvider:        &masterNetworkProviderObj,
		MasterStoragePolicy:    masterPolicyId, // GUID on submission
		MasterDNSSearchDomains: []string{masterDnsSearchDomains},
		MasterManagementNetwork: &namespace.MasterManagementNetwork{
			Mode: &namespace.StaticRangeIpAssignmentMode,
			AddressRange: &namespace.AddressRange{
				SubnetMask:      masterNetworkSubnetMask,
				StartingAddress: masterNetworkStartingAddressIpv4,
				Gateway:         masterNetworkGateway,
				AddressCount:    masterNetworkAddressCount,
			},
			Network: masterNetworkId,
		},
		MasterDNSNames: []string{masterDnsNames},
		// TODO TLS_MGMT_ENDPOINT_CERT?
		// TODO TLS ENDPOINT CERT?
		DefaultKubernetesServiceContentLibrary: defaultLibraryId, // GUID on
		NcpClusterNetworkSpec:                  nil,
		// TODO WORKLOAD NETWORKS
		// Option A: NSX-T:-
		// NcpClusterNetworkSpec: &namespace.NcpClusterNetworkSpec{
		// 	NsxEdgeCluster: "",
		// 	PodCidrs: []namespace.Cidr{
		// 		{
		// 			Address: "",
		// 			Prefix:  24,
		// 		},
		// 	},
		// 	EgressCidrs: []namespace.Cidr{
		// 		{
		// 			Address: "",
		// 			Prefix:  24,
		// 		},
		// 	},
		// 	ClusterDistributedSwitch: "",
		// 	IngressCidrs: []namespace.Cidr{
		// 		{
		// 			Address: "",
		// 			Prefix:  24,
		// 		},
		// 	},
		// },
		// Option B: VSPHERE NETWORKING
		WorkloadNetworksSpec: &namespace.WorkloadNetworksEnableSpec{
			SupervisorPrimaryWorkloadNetwork: &namespace.NetworksCreateSpec{
				NetworkProvider: &workloadNetworkProviderObj,
				VSphereNetwork: &namespace.VsphereDVPGNetworkCreateSpec{
					PortGroup: workloadNetworkPortgroup,
					AddressRanges: []namespace.IpRange{
						{
							Address: workloadNetworkStartingAddressIpv4,
							Count:   workloadNetworkAddressCount,
						},
					},
					SubnetMask: workloadNetworkSubnetMask,
					Gateway:    workloadNetworkGateway,
					// TODO IP Assignment mode on 7.0u3+
				},
				Network: workloadNetworkName,
			},
		},
		// Missing items, added since 7.0u1 and above:-
		WorkloadNTPServers: []string{workloadNtpServers},
		LoadBalancerConfigSpec: &namespace.LoadBalancerConfigSpec{
			Provider:      &lbTypeObj,
			AddressRanges: ranges,
			Id:            lbId,
			AviConfigCreateSpec: &namespace.AviConfigCreateSpec{
				Server: &namespace.LoadBalancersServer{
					Host: lbAviControllerHost,
					Port: lbAviControllerPort,
				},
				CertificateAuthorityChain: lbAviCaChain,
				Username:                  lbAviUsername,
				Password:                  lbAviPassword,
			},
		},
	}
	// TODO for options (vsphere vs nsxt, avi vs other), have logic here

	err := ns.EnableCluster(ctx, clusterId, spec)
	if err != nil {
		return diag.FromErr(err)
	}

	// The cluster ID upon enablement is the underlying vSphere Cluster
	d.SetId(clusterId)
	return diags
}

func resourceClusterRead(ctx context.Context, d *schema.ResourceData, m interface{}) diag.Diagnostics {
	// Warning or errors can be collected in a slice type
	var diags diag.Diagnostics
	// ns := m.(*namespace.Manager)
	// clusterList, err := ns.ListClusters(ctx)
	// if err != nil {
	// 	return diag.FromErr(err)
	// }

	found := false
	name := "unknown"
	// name := d.Get("name").(string)

	// // Now search for our (d.Id()) matching cluster
	// for _, cluster := range clusterList {
	// 	if cluster.Name == name {
	// 		found = true
	// 		d.SetId(cluster.ID)
	// 		if err := d.Set("id", cluster.ID); err != nil {
	// 			return diag.FromErr(err)
	// 		}
	// 		if err := d.Set("kubernetes_status", cluster.KubernetesStatus); err != nil {
	// 			return diag.FromErr(err)
	// 		}
	// 		if err := d.Set("config_status", cluster.ConfigStatus); err != nil {
	// 			return diag.FromErr(err)
	// 		}
	// 		// TODO all detail fields here too
	// 	}
	// }
	// Handle cluster not found error
	if !found {
		diags = append(diags, diag.Diagnostic{
			Severity: diag.Error,
			Summary:  "Unable to read Tanzu Supervisor Cluster",
			Detail:   "Cluster name not found: " + name,
		})
	}

	return diags
}

func flattenCluster(cluster namespace.ClusterSummary) map[string]interface{} {
	c := make(map[string]interface{})
	c["id"] = cluster.ID
	c["name"] = cluster.Name
	c["kubernetes_status"] = cluster.KubernetesStatus
	c["config_status"] = cluster.ConfigStatus

	return c
}

func resourceClusterUpdate(ctx context.Context, d *schema.ResourceData, m interface{}) diag.Diagnostics {
	return resourceClusterRead(ctx, d, m)
}

func resourceClusterDelete(ctx context.Context, d *schema.ResourceData, m interface{}) diag.Diagnostics {
	// Warning or errors can be collected in a slice type
	var diags diag.Diagnostics

	return diags
}
