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
and the [Avi Terraform Provider]().
An example of these being used alongside our Workload Management 
Terraform provider is provided in the 
examples/full_esxi_tanzu_cluster sample.

## Pre initial release sprints

- Alpha 1
   - Single Avi controller instance, Avi Essentials configuration only, v21.1.2
   - vDS networking 7.0u2 and 7.0u3 support for vCenter
   - Works with latest photon build for TKGS (see concourse/combinations/README.md)
   - Tested against h2o.vmware.com and my own homelab nested esxi environment
   - No automated CI/CD testing
   - Manual uploading of OVAs and manual Content Library creation
   - Add all necessary repo files (Update CLA from DCO, CONTRIBUTING changes for this too)
   - Support manual build only (Provider not yet added to Terraform registry)
   - Govmomi bug fixes and enhancements contributed back to project
   - REQUEST REPO BE MADE PUBLIC
- Alpha 2
   - Functional validation tests post cluster creation (Node up, node reachable)
   - Overarching Concourse tests for develop branch
   - Concourse loads environment combinations and runs multiple env pipelines in order using Terraform
     - Support n-2 photon versions
     - Automate testing on h20 (7.0u2) and homelab (7.0u3) using Concourse remote workers
     - This is a total of 6 combinations
   - Include initial vDS creation
   - Include file upload from staging to datastore
   - Include content library creation and uploading of TKR releases
   - Produce test report summary files for develop branch
   - Project introduction video
   - Support manual build only (Provider not yet added to Terraform registry)
- Beta 1
   - Beta builds submitted automatically to Terraform registry on tag and release (main branch)
   - Full sample documentation
   - Include support for TkgServiceConfiguration customisation
   - Include support for Custom ingress and egress CIDR ranges, CA certs
   - Include restriction of Certs used for EC P-256
   - Multi-node Avi controller support
   - Avi Enterprise support (including license key upload)
   - Add more version combinations
     - n-2 Avi version support
     - This is a total of 12 combinations
   - Bootstrap Harbor VM support
   - Helm Harbor services cluster support and sample
   - Node/pod communication check tests (VMs, Pods)
   - More detailed Concourse build success reports
- Beta 2
   - Add more version and environment combinations
     - Include basic Workload Cluster creation for photon and ubuntu TKR at n-2 (Only 2 supported currently)
     - Latest NSX-T support with own load balancer
     - This is 48 combinations in total
   - NSX-T support intro video
   - Built in Harbor support
   - Support for shared and standalone prometheus, grafana
- Initial full release
   - Add new environment and versions
     - NSX-T n-2 version support
     - NSX-T support with Avi load balancer
     - Latest ESXi/vSphere version tested (currently 7.0u3d)
     - n-2 tests for Avi Load Balancer, Avi Terraform Plugin (Matched to Avi), NSX-T and NSX-T Terraform Plugin (Matched to NSX-T)
     - This is 576 combinations
   - Full suite of tests (main and develop branches) with all latest minor releases of k8s TKRs
   - Tanzu Standard on top of vSphere for Tanzu, with restricted psp/opa
   - Istio with ingress, egress, istio-cni, minimum extra permissions (just the CNI pod)
   - Kiali support for istio configuration validation/manual checking
   - Full release documentation
   - Launch video


## Status (PRIOR TO INITIAL PUBLIC RELEASE ONLY, THEN REMOVED FROM HERE)

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
    - Implemented, untested, see examples/01_basic_create/clusters/main.tf
    - Uses hardcoded cluster enable spec data today
    - Limited to NSX-T today rather than full information due to missing govmomi features: https://github.com/vmware/govmomi/issues/2860
    - Warning: Due to the above, the workload cluster NTP source(s) will not be set, which will cause your workload clusters to not spin up successfully until you manually add this configuration element via vCenter
  - clusterRead()
    - Given a cluster NAME (NOT id) like 'Cluster01' returns the cluster's Tanzu Supervisor Cluster summary
    - Uses List method as data_clusters clusterRead today
    - Working, see see examples/02_basic_read/clusters/main.tf
    - Limited to cluster summary today rather than full information due to missing govmomi feature: https://github.com/vmware/govmomi/issues/2860
  - clusterUpdate()
    - Given a vSphere cluster ID (NOT name) like 'domain-c1005', replaces the current cluster enable spec with a new full spec
    - Not implemented today
  - clusterDelete()
    - Given a vSphere cluster ID (NOT name) like 'domain-c1005', disables workload management
    - Doesn't actually delete the vSphere cluster, just the Tanzu Supervisor Cluster
    - Not implemented

## Try it out

### Prerequisites

* You must have Terraform installed on your system
* You must have a Go runtime installed with corresponding build tools
* You must have a vSphere 7.0 update 2 (7.0.2) system configured with a vCenter and at least two hosts (ideally 3 or more)

## Building the provider

Run the following command to build the provider

```shell
go build -o terraform-provider-namespace-management
```

## Test sample configuration

First, build and install the provider.

```shell
make install
```

Download the simulator from here: 

TODO REWORK THIS SECTION TO NOT USE THE SIMULATOR

Now unpack and run the VMware simulator
```shell
cat ~/Downloads/vcsim_PLATFORM_ARCH.tar.gz | sudo tar -C /usr/local/bin -xzvf - vcsim
vcsim &
```

This will report `export GOVC_URL=https://user:pass@127.0.0.1:8989/sdk GOVC_SIM_PID=69867` when running

Then, run the following command to initialize the workspace and apply the sample configuration.

```shell
cd examples/SOME_EXAMPLE
terraform init && terraform apply
```

### Build & Run

1. Step 1
2. Step 2
3. Step 3

## Documentation

## Contributing

TODO REPLACE WITH CLA (As it's Apache 2)

The terraform-provider-namespace-management project team welcomes contributions from the community. Before you start working with terraform-provider-namespace-management, please
read our [Developer Certificate of Origin](https://cla.vmware.com/dco). All contributions to this repository must be
signed as described on that page. Your signature certifies that you wrote the patch or have the right to pass it on
as an open-source patch. For more detailed information, refer to [CONTRIBUTING.md](CONTRIBUTING.md).

## License

This project is licensed under the terms of the Apache-2.0 license and is Copyright VMware, Inc. 2022. See the LICENSE file for full details.