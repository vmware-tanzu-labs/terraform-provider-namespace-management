//  Copyright 2022 VMware, Inc.
//  SPDX-License-Identifier: Apache-2.0
//

package namespace_management

import (
	"context"
	"strconv"
	"time"

	"github.com/hashicorp/terraform-plugin-sdk/v2/diag"
	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/schema"

	"github.com/vmware/govmomi/vapi/namespace"
)

func dataSourceClusters() *schema.Resource {
	return &schema.Resource{
		ReadContext: dataSourceClustersRead,
		Schema: map[string]*schema.Schema{
			"clusters": {
				Type:     schema.TypeList,
				Computed: true,
				Elem: &schema.Resource{
					Schema: map[string]*schema.Schema{
						"id": {
							Type:     schema.TypeString,
							Computed: true,
						},
						"name": {
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
					},
				},
			},
		},
	}
}

func dataSourceClustersRead(ctx context.Context, d *schema.ResourceData, m interface{}) diag.Diagnostics {
	ns := m.(*namespace.Manager)
	clusterList, err := ns.ListClusters(ctx)
	if err != nil {
		return diag.FromErr(err)
	}

	var diags diag.Diagnostics

	clusters := make([]map[string]interface{}, 0)
	for _, cluster := range clusterList {
		cl := make(map[string]interface{})
		cl["id"] = cluster.ID
		cl["name"] = cluster.Name
		cl["kubernetes_status"] = cluster.KubernetesStatus
		cl["config_status"] = cluster.ConfigStatus

		clusters = append(clusters, cl)
	}

	if err := d.Set("clusters", clusters); err != nil {
		return diag.FromErr(err)
	}

	// always run
	d.SetId(strconv.FormatInt(time.Now().Unix(), 10))

	return diags
}
