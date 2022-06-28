
// Avi Provider variables
variable "avi_username" {
  type = string
  default = ""
}

# The NEW password to specify after installation
variable "avi_password" {
  type = string
  default = ""
  sensitive = true
}

variable "vm_datacenter" {
  type    = string
  default = "vc01"
}

variable "vm_resource_pool" {
  type    = string
  default = ""
}

variable "content_library" {
  type    = string
  default = ""
}

variable "vm_datastore" {
  type    = string
  default = ""
}

variable "vm_name" {
  type    = string
  default = ""
}

variable "vm_network" {
  type    = string
  default = ""
}

variable "vm_folder" {
  type    = string
  default = ""
}

variable "vm_template" {
  type    = string
  default = ""
}




// New variables for full OVA settings:-
// TODO support multiple avi controllers
variable "avi_management_hostname" {
  type = string
  default = "avi-controller-1"
}
variable "avi_management_ip_address" {
  type = string
  default = "10.2.0.50"
}

# The following is an integer but written as a string (Avi provider requirement)
variable "avi_management_subnet_mask_int" {
  type = string
  default = "24"
}
variable "avi_management_default_gateway" {
  type = string
  default = "10.2.0.1"
}