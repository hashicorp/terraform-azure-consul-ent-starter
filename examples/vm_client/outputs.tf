output "default_acl_token" {
  description = "Consul server default ACL token"
  sensitive   = true
  value       = random_uuid.consul_client_default_token.result
}

output "vm_scale_set_name" {
  description = "Name of Virtual Machine Scale Set"
  value       = azurerm_linux_virtual_machine_scale_set.consul_client.name
}
