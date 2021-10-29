# Azure License Storage Module

## Required variables

* `consul_license_filepath` - Path to location of Consul license file
* `key_vault_id` - ID of Key Vault in which the Consul license will be stored
* `resource_name_prefix` - Prefix placed before resource names

## Example usage

```hcl
module "license_storage" {
  source = "./modules/license_storage"

  consul_license_filepath = "./consul.hclic"
  key_vault_id            = "/subscriptions/.../resourceGroups/.../providers/Microsoft.KeyVault/vaults/..."
  resource_name_prefix    = "dev"
}
```
