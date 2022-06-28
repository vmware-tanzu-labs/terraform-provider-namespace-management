# vSphere + Tanzu + vSphere Networking (vDS) + NSX-ALB (Avi)

Provisions a full stack Tanzu system using vSphere networking and the NSX
Advanced Load Balancer (AKA Avi).

By default uses the Enterprise Edition mode - this is NOT the version provided
for free with Tanzu Basic and Tanzu Standard.

This module uses a vSphere Datastore but does not require a VSAN datastore.

TODO: Provide configuration options to limit to Essentials Edition config only.

## Dependencies

Requires avi_controller_vsphere and avi_configure_cloud_vsphere in this repository.
Uses our own namespace-management Provider, and the VMware Avi and Hashicorp vSphere
providers too.

## Limitations

vSphere with Tanzu can only be configured on vSphere clusters with 2 or more hosts.

vSphere with Tanzu has a limitation in that the Avi Cloud must be the Default-Cloud
and thus the Avi Service Engine (SE) Group must be the Default-Group too.
(Applies up to and including 7.0u3) 


