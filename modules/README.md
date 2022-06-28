# Terraform modules from the VMware vSphere with Tanzu Namespace Management project

We provide a set of Terraform modules for use to configure the entire 
system of Tanzu Kubernetes Grid up to and including workload clusters.

## System boundaries

There are several system components with boundaries for our project. We provide
not only Terraform Providers but also well maintained Terraform Modules
that you can refer to directly rather than copying/pasting code. We also provide
examples that use these modules which you should not link to, but instead copy
and customise for your own system environments.

This means that there are some things this project team does support, but also
quite a few things we stay clear of and do not support. These support boundaries
are explained below.

Note: By 'support' we mean open source project support through best efforts rather
than formal VMware product support.

### IaaS boundary

This involves using Terraform to provision services on top of vSphere that
are necessary in order to use Tanzu for vSphere.

This project provides Terraform modules for this, but only supports the
namespace-management provider ourselves, using other terraform providers
created and maintained by other teams for other components. Examples
of these other components are vSphere (resource pools, vm creation, networking),
NSX-T (software defined networking), Avi (Software defined advanced load 
balancing). We do support the terraform modules published by THIS project that
uses these externally maintained providers.

The top most layer of this boundary is a running Tanzu Supervisor Cluster
on top of vSphere.

Our terraform modules for this start with avi_, nsx_ and namespace_management_ in 
the modules folder.

### Kubernetes Workload Cluster boundary

This involves instantiating, configuring and securing a workload cluster on
top of a Tanzu for vSphere system.

We only provide a set of Terraform Modules for this. These all start with
tanzu_ in the modules folder.

This does include setting up common shared services on shared service clusters.

At this point you can have a shared services cluster providing services that
are configured manually by your devops teams, and stand up workload clusters
that are linked to these provisioned shared services.

### App Workload and orchestration boundary

This involves setting up cross-boundary CI/CD for software and platform updates
and configuring application to run in cluster.

Whilst we provide modules (tanzu_ named) to configure clusters we stop at the
shared service layer and do not automate these steps ourselves. This is because
this type of configuration is organisation specific, and typically managed in
a Platform as a Product approach by DevOps teams themselves.

This is where installing something like Tanzu Application Platform (TAP) and using
its Supply Chains is involved.

We neither provide Terraform modules or Providers for this layer.