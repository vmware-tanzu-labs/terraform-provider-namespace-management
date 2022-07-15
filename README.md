# Namespace Management Terraform provider

This Terraform Provider enables control of vSphere Workload Management.
This includes enabling or disabling workload management 
(effectively creating, and destroying, Tanzu Supervisor Clusters), 
and enabling or disabling supervisor cluster services.

The project is called namespace-management rather than tanzu-supervisor 
to be consistent with the vSphere API name which it wraps.

Note that Tanzu Workload Clusters should be requested by sending YAML 
configuration via kubectl to the appropriate Supervisor Cluster's 
vSphere namespace. There is no internal vSphere REST API for this by design.
(This is internalised in CAPV - Cluster API for vSphere).

Likewise, creating the underlying infrastructure in vSphere can be 
accomplished by using the 
[HashiCorp vSphere provider](https://registry.terraform.io/providers/hashicorp/vsphere)
and the [Avi Terraform Provider](https://registry.terraform.io/providers/vmware/avi).
An end to end example of these being used alongside our Workload Management 
Terraform provider is provided in the 
examples/full_esxi_tanzu_cluster sample.

## Planned feature sprints

- Alpha 1 (Completed Friday 15 Jul 2022)
   - Module: Single Avi controller instance, Avi Essentials configuration only, v21.1.2
   - Module: vDS networking 7.0u2 and 7.0u3 support for vCenter
   - Works with latest photon build for TKGS (see concourse/combinations/README.md)
   - Tested against h2o.vmware.com and my own homelab nested esxi environment
   - No automated CI/CD testing
   - Module: Manual uploading of OVAs and manual Content Library creation
   - Add all necessary repo files (Update CLA from DCO, CONTRIBUTING changes for this too)
   - Support manual build only (Provider not yet added to Terraform registry)
   - Add develop branch
   - REQUEST REPO BE MADE PUBLIC
- Alpha 2
   - Provider: Govmomi bug fixes and enhancements contributed back to project as PRs
   - Provider: Basic CI testing of Terraform Provider in isolation (In Go, via GitHub CI) for develop branch
   - Provider: Functional validation tests post cluster creation (Node up, node reachable)
   - Provider: Produce test report summary files for develop branch
   - Provider: Delete, create and status work as Terraform requires
   - Module: Include initial vDS creation
   - Module: Include file upload from staging to datastore
   - Module: Include content library creation and uploading of TKR releases
     - Offline 'local' support (Airgapped)
     - Online subscribed support (non Airgapped)
   - Project introduction video
   - Support manual build only (Provider not yet added to Terraform registry)
- Beta 1
   - Beta builds submitted automatically to Terraform registry on tag and release (main branch)
   - Full sample documentation
   - Provider: Custom CA cert support for Supervisor Cluster
   - Module: Multi-node Avi controller support
   - Module: Avi Enterprise support (including license key upload)
   - Module: More detailed build success reports
- Announcement email internal to VMware Tanzu SE community to try and test out
- Beta 2
   - Provider: NSX-T networking configuration support
   - Provider: Enable the built in Harbor on Supervisor Cluster
   - Module: Add more version and environment combinations
     - Include basic Workload Cluster creation for photon and ubuntu TKR at n-2 (Only 2 supported currently)
     - Latest NSX-T support with own load balancer
     - This is 48 combinations in total
   - Module: Support for shared and standalone prometheus, grafana
   - Release Testing: A Tagged branch results in an end to end test, and test results being added to a (Beta) release
   - NSX-T support intro video
- Beta 3
   - Provider: Create/delete namespace (With network, storage policy, resource limits, t-shirt sizes allowed)
   - Provider: Add/delete workload network
   - Provider: Assign/remove vSphere SSO group access to namespace
   - Provider: Apply license (and check license as per: https://developer.vmware.com/apis/vsphere-automation/latest/vcenter/namespace_management/hosts_config/)
   - Module: (Kubernetes Provider) Include support for TkgServiceConfiguration injection (and customisation) to Supervisor Cluster
   - Module: (Kubernetes Provider) Create workload cluster config and submit it
- Determine releasing version number convention (Recommend v1 until terraform config incompatability)
- v1.0 useable product at this point for end to end creation by customers
   - Provider: Add supported vSphere version check to enablement call
   - Pre-release documentation
     - Provider: Document supported vSphere versions
   - Pre-release videos
   - Work with OSPO and Tanzu teams for announcement
- v1.1 Day 2 operations focused
   - Module: Add new TKR release to Content Library
   - Provider: Add fail-fast checks (compatible networks, hosts, versions (TKR, vSphere, Avi, NSX-T, vDS Switch))
- v1.2 Security lockdown configuration simplification
   - Module: Include support for Custom ingress and egress CIDR ranges in TkgServiceConfiguration
   - Module: CA certs for all components
   - Module: Tests to verify ca cert changes
   - Module: Include restriction of Certs used for EC P-256
- v1.3 Workload cluster common patterns
   - Module: Bootstrap Harbor VM support (Requires a Harbor OVA)
   - Module: Helm Harbor services cluster support and sample (Requires a bootstrap harbor)
   - Module: Node/pod communication check tests (VMs, Pods)
- v1.4 End to End regression testing against our other products
   - Regression CD testing, via tag rather than commit
   - Provider: Overarching tests for develop branch
   - Provider: Concourse loads environment combinations and runs multiple env pipelines in order using Terraform
     - Support n-2 photon versions
     - Automate testing on h20 (7.0u2) and homelab (7.0u3) using remote workers
     - This is a total of 6 combinations
   - Module: Add more version combinations
     - n-2 Avi version support
     - This is a total of 12 combinations
- v1.5 Full testing suite for CD (No changes to Provider)
   - Add new environment and versions
     - NSX-T n-2 version support
     - NSX-T support with Avi load balancer
     - Latest ESXi/vSphere version tested (currently 7.0u3d)
     - n-2 tests for Avi Load Balancer, Avi Terraform Plugin (Matched to Avi), NSX-T and NSX-T Terraform Plugin (Matched to NSX-T)
     - This is 576 combinations
   - Full suite of tests (using tags on the main and develop branches) with all latest minor releases of k8s TKRs
   - Module: Tanzu Standard on top of vSphere for Tanzu, with restricted psp/opa
   - Istio with ingress, egress, istio-cni, minimum extra permissions (just the CNI pod)
   - Kiali support for istio configuration validation/manual checking
   - Full release documentation
   - Video
   - TODO Discuss with Automation team on additional features for their tool
- v? Other namespace-management API endpoints not discussed above
   - Based on customer feedback only
   - No other endpoints known used today
   - For a full list: https://developer.vmware.com/apis/vsphere-automation/latest/vcenter/namespace_management/
   - E.g. changing password rotation settings as per https://developer.vmware.com/apis/vsphere-automation/latest/vcenter/api/vcenter/namespace-management/clusters/clusteractionrotate_password/post/

## Namespace Management API support status

- data_source_clusters 
  - clustersRead()
    - lists clusters with id, name, k8s status, config status
    - Uses GET /api/vcenter/namespace-management/clusters
    - Working, see examples/03_basic_list/clusters/main.tf
    - Returns { clusters: [ {id: "domain-c1005", name:"Cluster01", kubernetes_status:"READY", config_status:"RUNNING"}, ... ] }
- data_source_cluster
  - clusterRead()
    - Given a cluster NAME (NOT id) like 'Cluster01' returns the cluster's Tanzu Supervisor Cluster summary
    - Uses GET /api/vcenter/namespace-management/clusters
    - Summary includes (only) id, name, kubernetes_status, config_status
    - Working, see see examples/02_basic_read/clusters/main.tf
    - Returns {id: "domain-c1005", name:"Cluster01", kubernetes_status:"READY", config_status:"RUNNING"}
- resource_cluster
  - clusterCreate()
    - Given a vSphere cluster ID (NOT name) like 'domain-c1005', enables workload management
    - Uses POST /api/vcenter/namespace-management/clusters/{cluster}?action=enable
    - Implemented, tested, see examples/01_basic_create/clusters/main.tf and examples/full_esxi_tanzu_cluster/main.tf
    - Only tested on vSphere networking (not NSX-T) today
  - clusterRead()
    - Given a cluster NAME (NOT id) like 'Cluster01' returns the cluster's Tanzu Supervisor Cluster summary
    - Uses List method as data_clusters clusterRead today
    - Working, see see examples/02_basic_read/clusters/main.tf
    - Limited to cluster summary today rather than full information due to missing govmomi feature: https://github.com/vmware/govmomi/issues/2860
      - Implies that we cannot implement clusterUpdate() too until this issue is resolved upstream
  - clusterUpdate()
    - Given a vSphere cluster ID (NOT name) like 'domain-c1005', replaces the current cluster enable spec with a new full spec
    - Not yet implemented
  - clusterDelete()
    - Given a vSphere cluster ID (NOT name) like 'domain-c1005', disables workload management
    - Doesn't actually delete the vSphere cluster, just the Tanzu Supervisor Cluster
    - Not yet implemented

## Try it out

### Prerequisites

* You must have Terraform installed on your system
* You must have a Go runtime installed with corresponding build tools
* You must have a vSphere 7.0 update 2 (7.0.2) or above system configured with a vCenter and at least ESXi two hosts (ideally 3 or more)

## Building the provider

Note that in the current version a patched release of Govmomi is required. You can fetch, build and install this from this URL: https://github.com/adamfowleruk/govmomi/tree/issue-2860 . We will remove this before the first major release once the fixes are applied in Govmomi.

Run the following command to build the provider

```shell
go build -o terraform-provider-namespace-management
```

## Test sample configuration

First, build and install the provider.

```shell
make install
```

Edit the sample file to customise it to your vSphere environment. You can find this in examples/02-basic-create/main.tf

Then, run the following command to initialize the workspace and apply the sample configuration.

```shell
cd examples/02-basic-create
terraform init && terraform apply
```

## Documentation

## Contributing

The terraform-provider-namespace-management project team welcomes contributions from the community. Before you start working with terraform-provider-namespace-management, please
Read our [Contributor License Agreement](https://cla.vmware.com/cla/1/preview). All contributions to this repository must be
signed as described on that page. Your signature certifies that you wrote the patch or have the right to pass it on
as an open-source patch. For more detailed information, refer to [CONTRIBUTING.md](CONTRIBUTING.md).

## License

This project is licensed under the terms of the Apache-2.0 license and is Copyright VMware, Inc. 2022. See the LICENSE file for full details.