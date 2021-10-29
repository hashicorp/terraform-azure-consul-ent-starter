output "client_identity_client_id" {
  description = "Managed identity client ID for Consul client instances"
  value       = module.iam.client_identity_client_id
}

output "client_identity_id" {
  description = "Managed identity for Consul client instances"
  value       = module.iam.client_identity_id
}

output "client_identity_principal_id" {
  description = "Managed identity principal ID for Consul client instances"
  value       = module.iam.client_identity_principal_id
}

output "license_secret_id" {
  description = "Key Vault Secret ID containing Consul license"
  value       = module.license_storage.license_secret_id
}

output "consul_version" {
  description = "Consul version"
  value       = var.consul_version
}

output "vm_scale_set_name" {
  description = "Name of servers Virtual Machine Scale Set"
  value       = module.vm.vm_scale_set_name
}
