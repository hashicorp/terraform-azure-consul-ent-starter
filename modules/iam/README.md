# Azure IAM Module

## Required variables

* `gossip_secret_id` - ID of Key Vault Secret in which the Consul gossip encryption key is stored
* `key_vault_id` - ID of Key Vault in which the Consul secrets (gossip encryption, license, TLS) are stored
* `license_secret_id` - ID of Key Vault Secret in which the Consul license is stored (can be omitted if `create_client_identity_id` is set to `false`)
* `resource_group` - Resource group in which resources will be deployed
* `resource_name_prefix` - Prefix placed before resource names
* `tenant_id` - Tenant ID for Azure subscription in which resources are being deployed

## Example usage

```hcl
data "azurerm_client_config" "current" {}

module "iam" {
  source = "./modules/iam"

  gossip_secret_id     = "https://mykeyvaultname.vault.azure.net/secrets/mykeyvaultgossipsecretname/12ab12ab12ab12ab12ab12ab12ab12ab"
  key_vault_id         = "/subscriptions/.../resourceGroups/.../providers/Microsoft.KeyVault/vaults/mykeyvaultname"
  license_secret_id    = "https://mykeyvaultname.vault.azure.net/secrets/mykeyvaultlicensesecretname/12ab12ab12ab12ab12ab12ab12ab12ab"
  resource_name_prefix = "dev"
  tenant_id            = data.azurerm_client_config.current.tenant_id

  resource_group = {
    id       = "/subscriptions/.../resourceGroups/myresourcegroupname"
    location = "eastus"
    name     = "myresourcegroupname"
  }
}
```
