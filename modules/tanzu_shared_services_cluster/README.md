# Tanzu Shared Services Cluster Terraform Module

This module instantiates a Tanzu Workload Cluster and
configures it for common shared services. All of the
shared services provisioned and configured use products
available in Tanzu Standard Runtime (on-prem, non-SaaS),
as part of Tanzu Data products (Postgres et al), or are
common opensource software available in VMware Application
Catalogue.

## Status

Concept phase - This module is a concept and not yet implemented, even as alpha/beta.

## Dependencies

Requires tanzu_workload_cluster within this repository.

## Components

The following are provided:-

1. Creation of a vSphere namespace (Default: devops-team)
1. Creation of a shared services cluster (Default: shared-services)
1. Installation of Tanzu Cluster Essentials (kapp-controller and cert-manager)
1. Installation of a HA Harbor cluster
1. Installing all containers and charts for other needed elements (allowing airgapped offline installation)
1. Installation of Prometheus and Grafana (including default Tanzu Grafana dashboards)
  - Also acts as a sink for prometheus metrics from other workload clusters
1. Installation of fluentd to act as a sink for log files from other workload clusters
  - Also sinks these logs to vRealize LogInsight, if available
  - TODO may sink these log files to OpenSearch in-cluster? (via VMware App Catalogue?)
1. Installation of GitLab Community Edition to provide code and config storage on-prem (VMware App Catalogue)
1. Installation of a Postgres HA instance for use by Terraform (Options for Tanzu support, or VMware App Catalogue OSS)
1. Installation of Concourse for Terraform CI/CD control plane
  - TODO consider tekton as well/instead of Concourse
  - This is to allow follow-on local management of other workload clusters
  - This module can be considered a 'bootstrap' for this future Terraform runner
  - Uses Postgres as its backend for the terraform runner via a kubernetes secret
  - Uses a GitLab project as the source for Concourse config changes
