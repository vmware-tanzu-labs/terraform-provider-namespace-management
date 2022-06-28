# GET namespace-management/cluster/{cluster_id}

Sample response:-

```json
{
    "cluster_proxy_config": {
        "proxy_settings_source": "VC_INHERITED"
    },
    "workload_ntp_servers": [
        "172.16.7.1"
    ],
    "image_storage": {
        "storage_policy": "379687da-922d-4b07-8810-88fe117628b3"
    },
    "api_servers": [
        "10.2.0.50",
        "172.16.7.16",
        "10.2.0.53",
        "172.16.7.17",
        "10.2.0.51",
        "172.16.7.18",
        "10.2.0.52"
    ],
    "api_server_management_endpoint": "10.2.0.50",
    "master_NTP_servers": [
        "10.2.0.1"
    ],
    "default_image_repository": "",
    "ephemeral_storage_policy": "379687da-922d-4b07-8810-88fe117628b3",
    "service_cidr": {
        "address": "10.96.0.0",
        "prefix": 23
    },
    "size_hint": "SMALL",
    "default_image_registry": {
        "hostname": "",
        "port": 443
    },
    "worker_DNS": [
        "172.16.7.1"
    ],
    "master_DNS": [
        "10.2.0.1"
    ],
    "network_provider": "VSPHERE_NETWORK",
    "master_storage_policy": "379687da-922d-4b07-8810-88fe117628b3",
    "master_DNS_search_domains": [
        "lab01.my.cloud"
    ],
    "stat_summary": {
        "cpu_used": 0,
        "storage_capacity": 0,
        "memory_used": 0,
        "cpu_capacity": 0,
        "memory_capacity": 0,
        "storage_used": 0
    },
    "api_server_cluster_endpoint": "172.16.6.18",
    "master_management_network": {
        "mode": "STATICRANGE",
        "address_range": {
            "subnet_mask": "255.255.255.0",
            "starting_address": "10.2.0.50",
            "gateway": "10.2.0.1",
            "address_count": 5
        },
        "network": "network-12"
    },
    "load_balancers": [
        {
            "avi_info": {
                "server": {
                    "port": 443,
                    "host": "10.2.0.48"
                },
                "certificate_authority_chain": "-----BEGIN CERTIFICATE-----\nREDACTED\n-----END CERTIFICATE-----",
                "username": "admin"
            },
            "address_ranges": [],
            "provider": "AVI",
            "id": "avi-lb"
        }
    ],
    "Master_DNS_names": [
        "k8s-supervisor-api-lb.lab01.my.cloud"
    ],
    "config_status": "RUNNING",
    "tls_management_endpoint_certificate": "-----BEGIN CERTIFICATE-----\nREDACTED\n-----END CERTIFICATE-----\n",
    "login_banner": "",
    "kubernetes_status": "READY",
    "kubernetes_status_messages": [],
    "tls_endpoint_certificate": "-----BEGIN CERTIFICATE-----\nREDACTED==\n-----END CERTIFICATE-----\n",
    "messages": [],
    "default_kubernetes_service_content_library": "fd58ca72-a439-4085-833e-05da5fd743b4",
    "workload_networks": {
        "supervisor_primary_workload_network": {
            "vsphere_network": {
                "portgroup": "dvportgroup-5025",
                "address_ranges": [
                    {
                        "address": "172.16.7.16",
                        "count": 239
                    }
                ],
                "subnet_mask": "255.255.255.0",
                "gateway": "172.16.7.1"
            },
            "network_provider": "VSPHERE_NETWORK",
            "namespaces": [
                "devteam-a",
                "devteam-b",
                "devops-team"
            ],
            "network": "k8s-workload01-network"
        }
    }
}
```