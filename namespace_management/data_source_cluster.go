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

func dataSourceCluster() *schema.Resource {
	return &schema.Resource{
		ReadContext: dataSourceClusterRead,
		Schema: map[string]*schema.Schema{
			"id": &schema.Schema{
				Type:     schema.TypeString,
				Optional: true,
			},
			"name": &schema.Schema{
				Type:     schema.TypeString,
				Required: true,
			},
			"kubernetes_status": &schema.Schema{
				Type:     schema.TypeString,
				Computed: true,
			},
			"config_status": &schema.Schema{
				Type:     schema.TypeString,
				Computed: true,
			},
		},
	}
}

func dataSourceClusterRead(ctx context.Context, d *schema.ResourceData, m interface{}) diag.Diagnostics {
	ns := m.(*namespace.Manager)
	clusterList, err := ns.ListClusters(ctx)
	if err != nil {
		return diag.FromErr(err)
	}

	var diags diag.Diagnostics
	found := false

	name := d.Get("name").(string)

	// Now search for our (d.Id()) matching cluster
	for _, cluster := range clusterList {
		if cluster.Name == name {
			found = true
			d.SetId(cluster.ID)
			if err := d.Set("id", cluster.ID); err != nil {
				return diag.FromErr(err)
			}
			if err := d.Set("kubernetes_status", cluster.KubernetesStatus); err != nil {
				return diag.FromErr(err)
			}
			if err := d.Set("config_status", cluster.ConfigStatus); err != nil {
				return diag.FromErr(err)
			}
		}
	}
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
