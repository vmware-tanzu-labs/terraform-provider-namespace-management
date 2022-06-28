//  Copyright 2022 VMware, Inc.
//  SPDX-License-Identifier: Apache-2.0
//

package main

import (
	"github.com/hashicorp/terraform-plugin-sdk/v2/plugin"

	"github.com/vmware/terraform-provider-namespace-management/namespace_management"
)

func main() {
	plugin.Serve(&plugin.ServeOpts{
		ProviderFunc: namespace_management.Provider})
}
