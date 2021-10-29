output "acl_tokens_secret_id" {
  description = "Key Vault Secret id where Consul server ACL tokens are stored"
  value       = azurerm_key_vault_secret.consul_server_acl_tokens.id
}

output "ca_cert" {
  description = "Certificate Authority public cert"
  value       = tls_self_signed_cert.ca.cert_pem
}

output "default_acl_token" {
  description = "Consul server default ACL token"
  sensitive   = true
  value       = random_uuid.consul_server_default_token.result
}

output "gossip_secret_id" {
  description = "Key Vault Secret id where Consul gossip key is stored"
  value       = azurerm_key_vault_secret.gossip_encryption.id
}

output "key_vault_id" {
  description = "Key Vault ID"
  value       = azurerm_role_assignment.terraform_client.scope
}

output "tls_secret_id" {
  description = "Key Vault Secret id where Consul server TLS cert info is stored"
  value       = azurerm_key_vault_secret.consul.id
}
