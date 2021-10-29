variable "common_tags" {
  description = "(Optional) Map of common tags for all taggable resources"
  type        = map(string)
}

variable "consul_license_filepath" {
  description = "Path to location of Consul license file"
  type        = string
}

variable "key_vault_id" {
  description = "Azure Key Vault in which the Consul license will be stored"
  type        = string
}

variable "resource_name_prefix" {
  description = "Prefix applied to resource names"
  type        = string
}
