variable "application_security_group_ids" {
  default     = null
  description = "Application Security Group IDs for the VMs"
  type        = list(string)
}

variable "ca_cert" {
  description = "Certificate Authority public certificate (used to sign the server certs)"
  type        = string
}

variable "common_tags" {
  default     = {}
  description = "(Optional) Map of common tags for all taggable resources"
  type        = map(string)
}

variable "consul_version" {
  default     = "1.10.2"
  description = "Consul version"
  type        = string
}

variable "gossip_secret_id" {
  description = "ID of Key Vault Secret where the Consul gossip encryption key is stored"
  type        = string
}

variable "health_check_path" {
  default     = "/v1/status/leader"
  description = "The endpoint for scale set health extension checks"
  type        = string
}

variable "identity_client_id" {
  description = "Client ID associated with \"identity_id\""
  type        = string
}

variable "identity_id" {
  description = "User assigned identity to use for Consul gossip encryption key & license retrieval"
  type        = string
}

variable "instance_count" {
  default     = 3
  description = "Number of Consul nodes to deploy in scale set"
  type        = number
}

variable "instance_type" {
  default     = "Standard_D2s_v3"
  description = "Scale set virtual machine SKU"
  type        = string
}

variable "key_vault_id" {
  description = "Azure Key Vault containing secrets"
  type        = string
}

variable "license_secret_id" {
  description = "Key Vault Secret containing the base64 encoded Consul Enterprise license file"
  type        = string
}

variable "os_disk_type" {
  default     = "Premium_LRS"
  description = "Disk type to use for VM instances"
  type        = string
}

variable "resource_group" {
  description = "Azure resource group in which resources will be deployed"

  type = object({
    id       = string
    name     = string
    location = string
  })
}

variable "resource_name_prefix" {
  description = "Prefix applied to resource names"
  type        = string
}

variable "server_vm_scale_set_name" {
  description = "VM Scale Set Name of Consul servers"
  type        = string
}

variable "ssh_public_key" {
  description = "Public key to use for SSH access to VMs"
  type        = string
}

variable "ssh_username" {
  default     = "azureuser"
  description = "Instance admin username"
  type        = string
}

variable "subnet_id" {
  description = "Subnet in which VMs will be deployed"
  type        = string
}

variable "ultra_ssd_enabled" {
  default     = true
  description = "Enable VM scale set Ultra SSD data disks compatibility"
  type        = bool
}

variable "user_supplied_source_image_id" {
  default     = null
  description = "(Optional) Image ID for Consul instances"
  type        = string
}

variable "user_supplied_userdata_path" {
  default     = null
  description = "(Optional) File path to custom VM configuration (i.e. cloud-init config) being supplied by the user"
  type        = string
}

variable "vm_scale_set_name" {
  default     = null
  description = "(Optional) VM Scale Set Name"
  type        = string
}

variable "zones" {
  description = "Azure availability zones for deployment"
  type        = list(string)

  default = [
    "1",
    "2",
    "3",
  ]
}
