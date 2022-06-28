//  Copyright 2022 VMware, Inc.
//  SPDX-License-Identifier: Apache-2.0
//

package namespace_management

import (
	"context"
	"net/url"

	"github.com/hashicorp/terraform-plugin-sdk/v2/diag"
	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/schema"

	"github.com/vmware/govmomi/session/cache"
	"github.com/vmware/govmomi/vapi/namespace"
	"github.com/vmware/govmomi/vapi/rest"
	"github.com/vmware/govmomi/vim25/debug"
)

// Provider -
func Provider() *schema.Provider {
	return &schema.Provider{
		Schema: map[string]*schema.Schema{
			"vsphere_hostname": &schema.Schema{
				Type:        schema.TypeString,
				Required:    true,
				DefaultFunc: schema.EnvDefaultFunc("VSPHERE_HOSTNAME", nil),
			},
			"vsphere_username": &schema.Schema{
				Type:        schema.TypeString,
				Required:    true,
				DefaultFunc: schema.EnvDefaultFunc("VSPHERE_USERNAME", nil),
			},
			"vsphere_password": &schema.Schema{
				Type:        schema.TypeString,
				Required:    true,
				Sensitive:   true,
				DefaultFunc: schema.EnvDefaultFunc("VSPHERE_PASSWORD", nil),
			},
			"vsphere_insecure": &schema.Schema{
				Type:     schema.TypeBool,
				Optional: true,
				Default:  false,
			},
		},
		ResourcesMap: map[string]*schema.Resource{
			"namespace-management_cluster": resourceCluster(),
		},
		DataSourcesMap: map[string]*schema.Resource{
			"namespace-management_cluster":  dataSourceCluster(),
			"namespace-management_clusters": dataSourceClusters(),
		},
		ConfigureContextFunc: providerConfigure,
	}
}

func providerConfigure(ctx context.Context, d *schema.ResourceData) (interface{}, diag.Diagnostics) {
	hostname := d.Get("vsphere_hostname").(string)
	username := d.Get("vsphere_username").(string)
	password := d.Get("vsphere_password").(string)
	insecure := d.Get("vsphere_insecure").(bool)

	var diags diag.Diagnostics

	debug.SetProvider(&debug.LogProvider{})

	if (hostname != "") && (username != "") && (password != "") {
		u, err := url.Parse("https://" + hostname)
		if err != nil {
			diags = append(diags, diag.Diagnostic{
				Severity: diag.Error,
				Summary:  "Unable to create vSphere GOVMOMI session cache",
				Detail:   "Unable to parse REST URL",
			})
			return nil, diags
		}
		u.User = url.UserPassword(username, password)
		restClient := new(rest.Client)
		s := &cache.Session{
			URL:      u,
			Insecure: insecure,
		}
		err = s.Login(ctx, restClient, nil)
		// TODO determine if we need to log the cached info anywhere in particular
		// (E.g. in the $PWD/.terraform folder, and not user .govmoni folder)

		if err != nil {
			diags = append(diags, diag.Diagnostic{
				Severity: diag.Error,
				Summary:  "Unable to login via vSphere GOVMOMI client",
				Detail:   "Unable to auth user for authenticated vSphere client",
			})
			return nil, diags
		}
		// this creates the client wrapper for NAMESPACE
		m := namespace.NewManager(restClient)
		// Note: We only set up a REST API as we only need that for vapi
		//       and namespace functionality - no SOAP required

		return m, diags
	}

	return nil, diags
}
