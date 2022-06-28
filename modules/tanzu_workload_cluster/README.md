# Tanzu Workload Cluster Terraform Module

This module creates a Tanzu Workload Cluster on vSphere with Tanzu and configures
minimum elements on the cluster. This includes default storage classes and other
minimum configuration.

This module can also optionally be instructed to sink all Prometheus metrics
and log files (using fluentbit) to a shared services cluster.

This module can also optionally configure Contour or Istio (TSM Istio Mode or OSS Istio)
to act as Ingress controllers, and exposes them via a load balancer.

TODO consider adding enforcement of namespace quotas linked to some concept of t-shirt
sizes.

## Status

Concept phase - This module is a concept and not yet implemented, even as alpha/beta.

## Dependencies

Assumes you have enabled workload management, but does not call this module directly.

Uses the Kubernetes Terraform provider.

## Components

This module always creates:-

- A new cluster using the v1alpha2 API (vSphere 7.0u2+ only) of Tanzu for vSphere
- Sets a default storage class
- Sets the CNI networking (Antrea or Antrea-NSX)
- Allows sizing, resilience, and network configuration overrides
- Restricts each Namespace to a separate Antrea isolated network area
- Assigns quota, permissions, and limits to any namespaces requested during creation
- Sets the default Harbor instance to use, and injects those secrets into namespaces created
  - Also adds an istio-injection=enabled/disabled flag to namespaces, if required
- Adds any in-kubernetes cluster role assignments to namespaces
- Installation of Tanzu Cluster Essentials (kapp-controller and cert-manager)

This module may also create with configure_metrics=true:-
- Sink metrics to a central Prometheus system; OR
- Set up Prometheus and Grafana in this cluster

This module may also create with configure_logs=true:-
- Sink logs using fluentbit to a shared fluentd engine

This module may also create with configure_contour=true:-
- Create a tanzu-system-ingress namespace configured with Contour
- Expose Contour via a load balancer

This module may also create with configure_istio=true:-
- Create an istiod namespace for istio system components
- Create an istio-ingress namespace as a default Ingress gateway
- Create an istio-egress namespace as a default Egress gateway
- Configure Istio injection into namespaces with an explicit istio-injection=enabled flag
- Instantiates a Kiali management UI and exposes this via its own separate load balancer