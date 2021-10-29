variable "acl_tokens_secret_id" {
  default     = null
  description = "Consul server ACL tokens Key Vault Secret ID"
  type        = string
}

variable "ca_cert" {
  description = "Certificate Authority public certificate (used to sign the server certs in secret \"tls_secret_id\")"
  type        = string
}

variable "consul_version" {
  default     = "1.10.2"
  description = "Consul version"
  type        = string
}

variable "gossip_secret_id" {
  description = "Key Vault Secret containing the gossip encryption key"
  type        = string
}

variable "instance_count" {
  description = "Number of Consul nodes to deploy in scale set"
  type        = number
}

variable "license_secret_id" {
  description = "Key Vault Secret containing the base64 encoded Consul Enterprise license file"
  type        = string
}

variable "resource_group" {
  description = "Azure resource group in which resources will be deployed"

  type = object({
    name = string
  })
}

variable "resource_name_prefix" {
  description = "Prefix applied to resource names"
  type        = string
}

variable "server_scale_set_name" {
  description = "Name for server virtual machine scale set"
  type        = string
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "tenant_id" {
  description = "Tenant ID"
  type        = string
}

variable "tls_secret_id" {
  description = "Key Vault Secret containing the TLS bundle (JSON with base64-encoded values or base64-encoded PFX) for TLS"
  type        = string
}

variable "user_supplied_userdata_path" {
  default     = null
  description = "File path to custom server VM configuration (i.e. cloud-init config) being supplied by the user"
  type        = string
}
