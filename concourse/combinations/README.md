# Supported combinations

We only test currently supported versions, and upcoming versions.
We presume upcoming versions are backward compatible with the latest
previous minor version unless told otherwise.

Note: Currently (July 2022) this project supports its modules and providers for
Terraform on a best efforts, open source basis. This is a Tanzu Labs project rather
than a fully VMware supported product offering at this time. If you'd like this to
change please provide regular feedback to your VMware Tanzu Sales Engineer.

Informal advice: Always use the most recent build of TKR available for the 
Supervisor cluster at the time of install, and use the most recent Ubuntu build
for the workload cluster at the time of workload cluster creation.

Note: 
- It is possible to run a ESXi/vSphere system at v7.0.3 but have a vDS configured
at v7.0.2. (The opposite isn't of course possible.)
- 'TESTING' means we have activated testing for the develop branch at least.
- 'FUTURE' means we aim to test this but haven't developed automation for this yet.
- [1] Means we're testing on a newly created build dynamically
- [2] Means we're testing on a 7.0.2 internal VMware environment (H2o)
- [3] Means we're testing on a 7.0.3 existing system (Adams Homelab)

|Combo Name|vSphere/ESXi|LB|Networking|Supervisor TKR|Workload TKR|Support Ends|Notes|
|---|---|---|---|---|---|---|---|
|**7.0.3e**|||||||
|SOON [3]|7.0.3e|Avi-21.1.2|vDS-7.0.2|v1.22.9---vmware.1-tkg.1.cc71bc8|v1.22.9---vmware.1-tkg.1.cc71bc8|?|CSI 2.4.1, Antrea 1.2.3. New Release. No known TKG issues|
|**7.0.3,7.0.3e**|||||||
|TESTING [2][3]|7.0.3|Avi-21.1.2|vDS-7.0.2|v1.22.9---vmware.1-tkg.1.cc71bc8|v1.22.9---vmware.1-tkg.1.cc71bc8|?|New Release. No known TKG Issues|
|TESTING [2][3]|7.0.3|Avi-21.1.2|vDS-7.0.2|v1.22.9---vmware.1-tkg.1.cc71bc8|ubuntu-2004-v1.21.6---vmware.1-tkg.1|?|Known TKG Issues|
|FUTURE [2][3]|7.0.3|Avi-21.1.2|vDS-7.0.2|v1.22.9---vmware.1-tkg.1.cc71bc8|ubuntu-2004-v1.20.8-vmware.1-tkg.2|?|For AI/ML. Known TKG Issues|
|FUTURE [2][3]|7.0.3|Avi-21.1.2|vDS-7.0.2|v1.22.9---vmware.1-tkg.1.cc71bc8|v1.21.6+vmware.1-tkg.1.b3d708a|?|Known TKG Issues|
||7.0.3|Avi-21.1.2|vDS-7.0.2|v1.22.9---vmware.1-tkg.1.cc71bc8|v1.21.2---vmware.1-tkg.1.ee25d55|?|Known TKG Issues|
|FUTURE|7.0.3|Avi-21.1.2|vDS-7.0.2|v1.21.6+vmware.1-tkg.1.b3d708a|v1.22.9---vmware.1-tkg.1.cc71bc8|?|Known TKG Issues|
|FUTURE|7.0.3|Avi-21.1.2|vDS-7.0.2|v1.21.6+vmware.1-tkg.1.b3d708a|ubuntu-2004-v1.21.6---vmware.1-tkg.1|?|Known TKG Issues|
|FUTURE|7.0.3|Avi-21.1.2|vDS-7.0.2|v1.21.6+vmware.1-tkg.1.b3d708a|ubuntu-2004-v1.20.8-vmware.1-tkg.2|?|For AI/ML. Known TKG Issues|
|TESTING [3]|7.0.3|Avi-21.1.2|vDS-7.0.2|v1.21.6+vmware.1-tkg.1.b3d708a|v1.21.6+vmware.1-tkg.1.b3d708a|?|Known TKG Issues|
||7.0.3|Avi-21.1.2|vDS-7.0.2|v1.21.6+vmware.1-tkg.1.b3d708a|v1.21.2---vmware.1-tkg.1.ee25d55|?|Known TKG Issues|
||7.0.3|Avi-21.1.2|vDS-7.0.2|v1.21.2---vmware.1-tkg.1.ee25d55|v1.22.9---vmware.1-tkg.1.cc71bc8|?|Known TKG Issues|
||7.0.3|Avi-21.1.2|vDS-7.0.2|v1.21.2---vmware.1-tkg.1.ee25d55|ubuntu-2004-v1.21.6---vmware.1-tkg.1|?|Known TKG Issues|
||7.0.3|Avi-21.1.2|vDS-7.0.2|v1.21.2---vmware.1-tkg.1.ee25d55|ubuntu-2004-v1.20.8-vmware.1-tkg.2|?|For AI/ML. Known TKG Issues|
||7.0.3|Avi-21.1.2|vDS-7.0.2|v1.21.2---vmware.1-tkg.1.ee25d55|v1.21.6+vmware.1-tkg.1.b3d708a|?|Known TKG Issues|
||7.0.3|Avi-21.1.2|vDS-7.0.2|v1.21.2---vmware.1-tkg.1.ee25d55|v1.21.2---vmware.1-tkg.1.ee25d55|?|Known TKG Issues|
|**7.0.2,7.0.3,7.0.3e**|||||||
|FUTURE|7.0.2|Avi-21.1.2|vDS-7.0.2|v1.22.9---vmware.1-tkg.1.cc71bc8|v1.20.12+vmware.1-tkg.1.b9a42f3|?|Known TKG Issues|
||7.0.2|Avi-21.1.2|vDS-7.0.2|v1.22.9---vmware.1-tkg.1.cc71bc8|v1.20.9+vmware.1-tkg.1.a4cee5b.900|?|Known TKG Issues|
|FUTURE|7.0.2|Avi-21.1.2|vDS-7.0.2|v1.22.9---vmware.1-tkg.1.cc71bc8|v1.19.16+vmware.1-tkg.1.df910e2|?|Known TKG Issues|
||7.0.2|Avi-21.1.2|vDS-7.0.2|v1.22.9---vmware.1-tkg.1.cc71bc8|v1.19.14+vmware.1-tkg.1.8753786.9254|?|Known TKG Issues|
||7.0.2|Avi-21.1.2|vDS-7.0.2|v1.21.6+vmware.1-tkg.1.b3d708a|v1.20.12+vmware.1-tkg.1.b9a42f3|?|Known TKG Issues|
||7.0.2|Avi-21.1.2|vDS-7.0.2|v1.21.6+vmware.1-tkg.1.b3d708a|v1.20.9+vmware.1-tkg.1.a4cee5b.900|?|Known TKG Issues|
||7.0.2|Avi-21.1.2|vDS-7.0.2|v1.21.6+vmware.1-tkg.1.b3d708a|v1.19.16+vmware.1-tkg.1.df910e2|?|Known TKG Issues|
||7.0.2|Avi-21.1.2|vDS-7.0.2|v1.21.6+vmware.1-tkg.1.b3d708a|v1.19.14+vmware.1-tkg.1.8753786.9254|?|Known TKG Issues|
|FUTURE|7.0.2|Avi-21.1.2|vDS-7.0.2|v1.20.12+vmware.1-tkg.1.b9a42f3|v1.20.12+vmware.1-tkg.1.b9a42f3|?|Known TKG Issues|
||7.0.2|Avi-21.1.2|vDS-7.0.2|v1.20.12+vmware.1-tkg.1.b9a42f3|v1.20.9+vmware.1-tkg.1.a4cee5b.900|?|Known TKG Issues|
|FUTURE|7.0.2|Avi-21.1.2|vDS-7.0.2|v1.20.12+vmware.1-tkg.1.b9a42f3|v1.19.16+vmware.1-tkg.1.df910e2|?|Known TKG Issues|
||7.0.2|Avi-21.1.2|vDS-7.0.2|v1.20.12+vmware.1-tkg.1.b9a42f3|v1.19.14+vmware.1-tkg.1.8753786.9254|?|Known TKG Issues|
|FUTURE|7.0.2|Avi-21.1.2|vDS-7.0.2|v1.19.16+vmware.1-tkg.1.df910e2|v1.20.12+vmware.1-tkg.1.b9a42f3|?|Known TKG Issues|
||7.0.2|Avi-21.1.2|vDS-7.0.2|v1.19.16+vmware.1-tkg.1.df910e2|v1.20.9+vmware.1-tkg.1.a4cee5b.900|?|Known TKG Issues|
|FUTURE|7.0.2|Avi-21.1.2|vDS-7.0.2|v1.19.16+vmware.1-tkg.1.df910e2|v1.19.16+vmware.1-tkg.1.df910e2|?|Known TKG Issues|
||7.0.2|Avi-21.1.2|vDS-7.0.2|v1.19.16+vmware.1-tkg.1.df910e2|v1.19.14+vmware.1-tkg.1.8753786.9254|?|Known TKG Issues|
||7.0.2|Avi-21.1.2|vDS-7.0.2|v1.18.19+vmware.1-tkg.1.17af790|v1.20.12+vmware.1-tkg.1.b9a42f3|?|Known TKG Issues|
||7.0.2|Avi-21.1.2|vDS-7.0.2|v1.18.19+vmware.1-tkg.1.17af790|v1.20.9+vmware.1-tkg.1.a4cee5b.900|?|Known TKG Issues|
||7.0.2|Avi-21.1.2|vDS-7.0.2|v1.18.19+vmware.1-tkg.1.17af790|v1.19.16+vmware.1-tkg.1.df910e2|?|Known TKG Issues|
||7.0.2|Avi-21.1.2|vDS-7.0.2|v1.18.19+vmware.1-tkg.1.17af790|v1.19.14+vmware.1-tkg.1.8753786.9254|?|Known TKG Issues|

## Why aren't they all tested?

We're looking to test all combinations pre-release, but in the meantime there's some rationale
in what we are testing:-

* We test the latest TKR version when the vSphere for Tanzu version was released - as many people will have moved to this immediately (Fresh installs)
* We test the latest combination as TKRs are released - which over time will pick up most likely combinations (through regression testing and release testing) (Similar to customer upgrade patterns)
* We test the last 3 (n-2) supported minor versions of kubernetes in line with their support policy on both photon and ubuntu (ubuntu was only supported in TKGS since 7.0.3)
  - Note: The latest K8S public release may be 1.23.x but we won't drop 1.19.x testing until VMware releases a TKR for 1.23.x (So we always have n-2 on what is available to customers)

We also don't test versions that have been withdrawn due to a CVE. You can see these mentioned in 'Additional Tanzu Kubernetes Releases' at the bottom
of this page: https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-releases/services/rn/vmware-tanzu-kubernetes-releases-release-notes/index.html#compatibility-for-vmware-tanzu-kubernetes-releases


## Background information

For TKR Release notes see: https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-releases/services/rn/vmware-tanzu-kubernetes-releases-release-notes/index.html

For SUPPORTED combinations see: https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-releases/services/rn/vmware-tanzu-kubernetes-releases-release-notes/index.html#compatibility-for-vmware-tanzu-kubernetes-releases

1.22.x
photon-3-k8s-v1.22.9---vmware.1-tkg.1.cc71bc8

1.21.x
ubuntu-2004-v1.21.6---vmware.1-tkg.1
photon-3-k8s-v1.21.6+vmware.1-tkg.1.b3d708a
photon-3-k8s-v1.21.2---vmware.1-tkg.1.ee25d55

1.20.x
photon-3-k8s-v1.20.12+vmware.1-tkg.1.b9a42f3
photon-3-k8s-v1.20.9---vmware.1-tkg.1.a4cee5b
ubuntu-2004-v1.20.8---vmware.1-tkg.2


1.19.x
photon-3-k8s-v1.19.16+vmware.1-tkg.1.df910e2
photon-3-k8s-v1.19.14---vmware.1-tkg.1.8753786

