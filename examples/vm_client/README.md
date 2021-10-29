# EXAMPLE: Client VM Scale Set

## About This Example

This example creates Consul client nodes, using the main module's shared client resources and creating the necessary per-client resources. Once the client nodes are provisioned, you must create an ACL policy for them and attach the pre-generated token (similar to what is shown in the main module [README](https://github.com/hashicorp/terraform-azure-consul-ent-starter/blob/main/README.md) for the servers) before they are able to join the Consul cluster using cloud auto-join.

## How to Use This Module

1. Ensure Azure credentials are [in place](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#authenticating-to-azure) (e.g. `az login` and `az account set --subscription="SUBSCRIPTION_ID"` on your workstation)
2. Set the required (and optional as desired) variables, e.g. `terraform.tfvars`:
```
# client_application_security_group_id output (as a single item in
# the list) from the example vnet module
application_security_group_ids = ["/subscriptions/.../resourceGroups/myresourcegroupname/providers/Microsoft.Network/applicationSecurityGroups/dev-consul-clients"]

# ca_cert output from the example key_vault module
ca_cert = <<-EOH
-----BEGIN CERTIFICATE-----
...
-----END CERTIFICATE-----
EOH

# gossip_secret_id output from the example key_vault module
gossip_secret_id = "https://mykeyvaultname.vault.azure.net/secrets/mykeyvaultgossipsecretname/12ab12ab12ab12ab12ab12ab12ab12ab"

# client_identity_client_id output from the main server module
identity_client_id = "abc123ab-c123-abc1-23ab-c123abc123ab"

# client_identity_id output from the main server module
identity_id = "/subscriptions/.../resourceGroups/.../providers/Microsoft.ManagedIdentity/userAssignedIdentities/dev-consul-client"

# key_vault_id output from the example key_vault module
key_vault_id = "/subscriptions/.../resourceGroups/.../providers/Microsoft.KeyVault/vaults/mykeyvaultname"

# license_secret_id output from the example key_vault module
license_secret_id = "https://mykeyvaultname.vault.azure.net/secrets/mykeyvaultlicensesecretname/12ab12ab12ab12ab12ab12ab12ab12ab"

resource_group = {
  location = "East US"
  name     = "My Resource Group Name"
}

resource_name_prefix = "dev"

# vm_scale_set_name output from the main server module
server_vm_scale_set_name = "dev-consul-servers"

ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADA..."

# consul_subnet_id output from the example vnet module
subnet_id = /subscriptions/.../resourceGroups/myresourcegroupname/providers/Microsoft.Network/virtualNetworks/myvnetname/subnets/myconsulsubnetname"
```
3. Run `terraform init` and `terraform apply`
4. Create an appropriate ACL policy for the nodes and associate the clients' token (`default_acl_token` output) with it

Then see the end of the [userdata template](./templates/install_consul_client.sh.tpl) for notes on integrating your application.

## Required Variables

* `application_security_group_ids` - List of application security groups to which the VMs' network interfaces will be associated
* `ca_cert` - Public key of Certificate Authority used to sign server TLS certs
* `gossip_secret_id` - ID of Key Vault Secret in which the Consul gossip encryption key is stored
* `identity_client_id ` - Client ID associated with "identity_id"
* `identity_id` - User assigned identity to use for Consul gossip encryption key & license retrieval
* `key_vault_id` - ID of Key Vault in which the Consul secrets (gossip encryption, license, TLS) are stored
* `license_secret_id` - ID of Key Vault Secret in which the Consul license is stored
* `resource_group` - [Azure Resource Group](https://github.com/hashicorp/terraform-azure-consul-ent-starter/tree/main/examples/resource_group) in which resources will be deployed
* `resource_name_prefix` - Prefix placed before resource names
* `server_scale_set_name` - Name of Consul servers VM Scale Set
* `ssh_public_key` - Public key permitted to access the VMs (as `azureuser` by default)
* `subnet_id` - Subnet in which the VMs will be deployed
