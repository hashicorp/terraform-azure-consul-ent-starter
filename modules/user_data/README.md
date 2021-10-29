# Azure User Data Module

## Required variables

* `acl_tokens_secret_id` - ID of Key Vault Secret containing the server ACL token(s)
* `ca_cert` - Certificate Authority public cert associated with TLS keypair in `tls_secret_id`
* `consul_version` - Version of Consul Enterprise to deploy
* `gossip_secret_id` - ID of Key Vault Secret in which the Consul gossip encryption key is stored
* `instance_count` - Number of expected servers in scale set
* `license_secret_id` - ID of Key Vault Secret in which the Consul license is stored (can be omitted if `create_client_identity_id` is set to `false`)
* `resource_group` - Resource group in which resources will be deployed
* `resource_name_prefix` - Prefix placed before resource names
* `server_scale_set_name` - Name of Consul servers VM Scale Set
* `subscription_id` - ID of Azure subscription
* `tenant_id` - Tenant ID for Azure subscription in which resources are being deployed
* `tls_secret_id` - ID of Key Vault Secret containing the TLS bundle

## Example usage

```hcl
data "azurerm_client_config" "current" {}

module "user_data" {
  source = "./modules/user_data"

  acl_tokens_secret_id  = "https://mykeyvaultname.vault.azure.net/secrets/mykeyvaulttokenssecretname/12ab12ab12ab12ab12ab12ab12ab12ab"
  ca_cert               = file("./cacert.pem")
  consul_version        = "1.10.2"
  gossip_secret_id      = "https://mykeyvaultname.vault.azure.net/secrets/mykeyvaultgossipsecretname/12ab12ab12ab12ab12ab12ab12ab12ab"
  instance_count        = 5
  license_secret_id     = "https://mykeyvaultname.vault.azure.net/secrets/mykeyvaultlicensesecretname/12ab12ab12ab12ab12ab12ab12ab12ab"
  resource_name_prefix  = "dev"
  server_scale_set_name = "dev-consul-server"
  subscription_id       = data.azurerm_client_config.current.subscription_id
  tenant_id             = data.azurerm_client_config.current.tenant_id
  tls_secret_id         = "https://mykeyvaultname.vault.azure.net/secrets/mykeyvaulttlssecretname/12ab12ab12ab12ab12ab12ab12ab12ab"

  resource_group = {
    name     = "myresourcegroupname"
  }
}
```
