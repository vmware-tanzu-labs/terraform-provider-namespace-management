# Full vSphere with Tanzu rollout example

## Folder notes

* 01_vcenter_create - not used today, kept as an example
* 02_vcenter_join - not used today, kept as an example
* 03_vds_networking - not used today, kept as an example
* 04_avi_controller - Deploys the initial Avi controller (only 1 today) and changes its password for access
* 05_avi_configure - Reconfigures an Avi controller's Default Cloud for vCenter and Tanzu networking
* 06_tanzu_enable - Deploy vSphere with Tanzu using vDS networking and Avi load balancing

The main.tf file uses modules 04 to 06 today. This has been tested against:-

* H2o within VMware, our demo environment, over company VPN, a ESXi vSphere 7.0u2 environment
* Adam's Homelab, a 3 node nested ESXi vSphere 7.0u3 environment

## Support statement

The files in this folder are SAMPLES ONLY, they are not designed as fully tested
or reusable Terraform modules. See the /modules folder for that ongoing work.

These files may be useful in a custom deployment or in troubleshooting
your own issues.

## Running the example

```sh
terraform init && terraform apply --var-file adams-homelab.tfvars \
  --var vsphere_password="Obvious1!" \
  --var vsphere_insecure=true \
  --var avi_password="Obvious1!" \
  --var avi_backup_passphrase="Obvious1!" \
```