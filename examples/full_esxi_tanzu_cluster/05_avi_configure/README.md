# avi system configuration notes


## Incorrect default cloud deletion

After initial config, always tries to delete cloud on apply

```sh
module.avi-config.avi_cloud.default_cloud: Destroying... [id=https://10.220.50.10/api/cloud/cloud-583cf9bd-cf88-4558-9965-1c782fe6df6d]
module.avi-config.avi_cloud.default_cloud: Still destroying... [id=https://10.220.50.10/api/cloud/cloud-583cf9bd-cf88-4558-9965-1c782fe6df6d, 10s elapsed]
module.avi-config.avi_cloud.default_cloud: Destruction complete after 14s
module.avi-config.avi_backupconfiguration.avi_backup_config: Creating...
╷
│ Error: Encountered an error on PUT request to URL https://10.220.50.10/api/backupconfiguration/backupconfiguration-4186c3ee-f669-47a7-ad0e-ddf5779d5e35?skip_default=true: HTTP code: 400; error from Avi: map[error:Atleast one backup destination needs to be provided]
│
│   with module.avi-config.avi_backupconfiguration.avi_backup_config,
│   on 05_avi_configure/main.tf line 30, in resource "avi_backupconfiguration" "avi_backup_config":
│   30: resource "avi_backupconfiguration" "avi_backup_config" {
  ```

```sh

module.avi-config.avi_cloud.default_cloud: Destroying... [id=https://10.220.50.10/api/cloud/cloud-583cf9bd-cf88-4558-9965-1c782fe6df6d]
module.avi-config.avi_cloud.default_cloud: Still destroying... [id=https://10.220.50.10/api/cloud/cloud-583cf9bd-cf88-4558-9965-1c782fe6df6d, 10s elapsed]
module.avi-config.avi_cloud.default_cloud: Destruction complete after 11s
module.avi-config.avi_backupconfiguration.avi_backup_config: Modifying... [id=https://10.220.50.10/api/backupconfiguration/backupconfiguration-4186c3ee-f669-47a7-ad0e-ddf5779d5e35]
module.avi-config.avi_backupconfiguration.avi_backup_config: Modifications complete after 1s [id=https://10.220.50.10/api/backupconfiguration/backupconfiguration-4186c3ee-f669-47a7-ad0e-ddf5779d5e35]
module.avi-config.avi_systemconfiguration.avi_system_config: Modifying... [id=https://10.220.50.10/api/systemconfiguration]
module.avi-config.avi_systemconfiguration.avi_system_config: Modifications complete after 0s [id=https://10.220.50.10/api/systemconfiguration]
module.avi-config.avi_cloud.default_cloud: Creating...
╷
│ Error: Encountered an error on PUT request to URL https://10.220.50.10/api/cloud/cloud-583cf9bd-cf88-4558-9965-1c782fe6df6d?skip_default=true: HTTP code: 400; error from Avi: map[error:Change of Vcenter URL/Datacenter for a vCenter cloud is not supported. Please delete the cloud and create a new one]
│
│   with module.avi-config.avi_cloud.default_cloud,
│   on 05_avi_configure/main.tf line 81, in resource "avi_cloud" "default_cloud":
│   81: resource "avi_cloud" "default_cloud" {
```

Note: This is caused by delete not changing the Default Cloud. After
applying config it is IMPOSSIBLE to modify the Default-Cloud, thus
we should avoid ever using the Default-Cloud with Terraform.

