variable "application_security_group_ids" {
  description = "Application Security Group IDs for the VMs"
  type        = list(string)
}

variable "common_tags" {
  default     = {}
  description = "(Optional) Map of common tags for all taggable resources"
  type        = map(string)
}

variable "health_check_path" {
  description = "The endpoint for scale set health extension checks"
  type        = string
}

variable "identity_ids" {
  description = "User assigned identities to apply to the VMs"
  type        = list(string)
}

variable "instance_count" {
  description = "Number of Consul nodes to deploy in scale set"
  type        = number
}

variable "instance_type" {
  default     = "Standard_D2s_v3"
  description = "Scale set virtual machine SKU"
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
    name     = string
    location = string
  })
}

variable "resource_name_prefix" {
  description = "Prefix applied to resource names"
  type        = string
}

variable "rolling_upgrade_policy" {
  description = "Scale Set rolling upgrade policy (used when \"upgrade_mode\" is set to Rolling or Automatic)"

  default = {
    max_batch_instance_percent              = 20
    max_unhealthy_instance_percent          = 20
    max_unhealthy_upgraded_instance_percent = 20
    pause_time_between_batches              = "PT1M"
  }

  type = object({
    max_batch_instance_percent              = number
    max_unhealthy_instance_percent          = number
    max_unhealthy_upgraded_instance_percent = number
    pause_time_between_batches              = string
  })
}

variable "scale_set_name" {
  description = "Name for virtual machine scale set"
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

variable "upgrade_mode" {
  default     = "Rolling"
  description = "Scale Set upgrade mode"
  type        = string
}

variable "user_data" {
  description = "User data for VM configuration"
  type        = string
}

variable "user_supplied_source_image_id" {
  default     = null
  description = "(Optional) Image ID for Consul instances"
  type        = string
}

variable "zones" {
  default     = null
  description = "Azure availability zones for deployment"
  type        = list(string)
}
