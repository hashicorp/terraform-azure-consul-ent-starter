# EXAMPLE: Key Vault creation and configuration

## About This Example

The Consul installation module requires a Key Vault with a few Secrets provisioned in it:

### TLS

A TLS secret, containing a TLS keypair, must be provided. If you do not already have a Key Vault and existing TLS certs that you can use for these requirements, one will be created and stored in the Key Vault in `tls.tf`.

NOTE: These are example certs valid for a very short period of time (30 days) - *at an absolute minimum*, these expiration dates will need to be adjusted before using them in production. You are advised to implement/use an appropriate TLS management strategy for your organization. 

### Gossip

A [gossip encryption key](https://www.consul.io/docs/security/encryption) will be generated and stored in the Key Vault in `gossip_key.tf`.

### ACL Token

An [ACL token](https://learn.hashicorp.com/tutorials/consul/access-control-setup-production) will be generated and stored in the Key Vault in `acl.tf`.

## How to Use This Module

1. Ensure Azure credentials are [in place](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#authenticating-to-azure) (e.g. `az login` and `az account set --subscription="SUBSCRIPTION_ID"` on your workstation)
2. Set the required (and optional as desired) variables, e.g. `terraform.tfvars`:
```
resource_group = {
  location = "East US"
  name = "My Resource Group Name"
}
```
3. Run `terraform init` and `terraform apply`

### Security Notes

#### Terraform State

The [Terraform State](https://www.terraform.io/docs/language/state/index.html) produced by this code has sensitive data (cert private keys) stored in it.

Please secure your Terraform state using the [recommendations listed here](https://www.terraform.io/docs/language/state/sensitive-data.html#recommendations).

#### Key Vault Firewall

The Key Vault can optionally be [configured to retrict access to specified IP addresses and networks](https://docs.microsoft.com/en-us/azure/application-gateway/key-vault-certs#how-integration-works); this is an additional layer of security (it doesn't replace Access Policies, just supplements them).

On the Key Vault resource:
```
  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
    ip_rules       = ["<MY_IP_ADDRESS_HERE>/32"]

    virtual_network_subnet_ids = [
      azurerm_subnet_network_security_group_association.consul.id,
    ]
  }
```

## Required Variables

* `resource_group` - [Azure Resource Group](../resource_group) in which resources will be deployed

## Note

- Please note the following output produced by this Terraform module as this information will be required input for the Consul installation module:
  - `acl_tokens_secret_id`
  - `ca_cert`
  - `gossip_secret_id`
  - `key_vault_id`
  - `tls_secret_id`
