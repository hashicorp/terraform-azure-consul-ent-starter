# Consul Azure Module

This is a Terraform module for provisioning Consul Enterprise on Azure. This module defaults to setting up a cluster with 5 Consul server nodes (as recommended by the [Consul Reference Architecture](https://learn.hashicorp.com/tutorials/consul/reference-architecture#failure-tolerance)).

## About This Module

This module implements the [Consul Reference Architecture](https://learn.hashicorp.com/tutorials/consul/reference-architecture) on Azure using the Enterprise version of Consul 1.10+.

## How to Use This Module

- Ensure Azure credentials are [in place](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#authenticating-to-azure) (e.g. `az login` and `az account set --subscription="SUBSCRIPTION_ID"` on your workstation)
    - Owner role or equivalent is required (to create the Azure roles for servers)

- Ensure pre-requisite resources are created:
    - [Resource Group](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal#what-is-a-resource-group)
        - See this [Resource Group module](https://github.com/hashicorp/terraform-azure-consul-ent-starter/tree/main/examples/resource_group) for an example implementation
    - [Virtual Network Subnet](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-overview) and associated [Network Security Groups](https://docs.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview)/[Application Security Groups](https://docs.microsoft.com/en-us/azure/virtual-network/application-security-groups)
        - See this [Virtual Network module](https://github.com/hashicorp/terraform-azure-consul-ent-starter/tree/main/examples/vnet) for an example implementation
    - [Key Vault](https://azure.microsoft.com/en-us/services/key-vault/) with a TLS Certificate bundle, gossip encryption key, and server acl token stored as individual Key Vault Secrets.
        - See this [Key Vault module](https://github.com/hashicorp/terraform-azure-consul-ent-starter/tree/main/examples/key_vault) for an example implementation

- Create a Terraform configuration that pulls in this module and specifies values for the required variables:

```hcl
provider "azurerm" {
  features {}
}

module "consul-ent" {
  source  = "hashicorp/consul-ent-starter/azure"
  version = "0.1.0"

  # ID of Key Vault Secret containing the server ACL token(s)
  acl_tokens_secret_id  = "https://mykeyvaultname.vault.azure.net/secrets/mykeyvaulttokenssecretname/12ab12ab12ab12ab12ab12ab12ab12ab"

  # List of application security groups to which the VMs' network interfaces will be associated
  application_security_group_ids = ["/subscriptions/.../resourceGroups/myresourcegroupname/providers/Microsoft.Network/applicationSecurityGroups/dev-consul-ingress", ...]

  # Certificate Authority public cert associated with TLS keypair in `tls_secret_id`
  ca_cert = file("./cacert.pem")

  # Path to the Consul Enterprise license file
  consul_license_filepath = "./consul.hclic"

  # ID of Key Vault Secret containing the gossip encryption key
  gossip_secret_id  = "https://mykeyvaultname.vault.azure.net/secrets/mykeyvaulttokenssecretname/12ab12ab12ab12ab12ab12ab12ab12ab"

  # Key Vault containing the secrets
  key_vault_id = "/subscriptions/.../resourceGroups/.../providers/Microsoft.KeyVault/vaults/..."

  # Resource group object in which resources will be deployed
  resource_group = {
    id       = "/subscriptions/.../resourceGroups/myresourcegroupname"
    location = "eastus"
    name     = "myresourcegroupname"
  }

  # Prefix for resource names
  resource_name_prefix = "dev"

  # SSH public key (for authentication to Consul servers)
  ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADA..."

  # Virtual Network subnet for Consul VMs
  subnet_id = "/subscriptions/.../resourceGroups/myresourcegroupname/providers/Microsoft.Network/virtualNetworks/myvnetname/subnets/myconsulsubnetname"

  # ID of Key Vault Secret containing the server TLS bundle
  tls_secret_id  = "https://mykeyvaultname.vault.azure.net/secrets/mykeyvaulttlssecretname/12ab12ab12ab12ab12ab12ab12ab12ab"
}
```

- Run `terraform init` and `terraform apply`

- You must [bootstrap](https://www.consul.io/commands/acl/bootstrap) your Consul cluster's ACL system after you create it. Begin by SSHing into your Consul cluster.
    - The [example Virtual Network module](https://github.com/hashicorp/terraform-azure-consul-ent-starter/tree/main/examples/vnet) deploys (optionally but enabled by default) the [Azure Bastion Service](https://docs.microsoft.com/en-us/azure/bastion/bastion-overview) to allow this via the Azure Portal.

- To bootstrap the Consul cluster, run the following commands:

```bash
consul acl bootstrap
```

- Please securely store the bootstrap token (shown as the `SecretID`) the Consul returns to you.
- Use the bootstrap token to create an appropriate policy for your Consul servers and associate their token with it. E.g., assuming `dev` as the module's `resource_name_prefix`:

```bash
export CONSUL_HTTP_TOKEN="<your bootstrap token>"
cat << EOF > consul-servers-policy.hcl
node_prefix "dev-consul-server" {
  policy = "write"
}

operator = "write"
EOF
consul acl policy create -name consul-servers -rules @consul-servers-policy.hcl
consul acl token create -policy-name consul-servers -secret "<your server token in acl_tokens_secret_id>"
unset CONSUL_HTTP_TOKEN
```

- To check the status of your Consul cluster, run the [list-peers](https://www.consul.io/commands/operator/raft#list-peers) command:

```bash
consul operator raft list-peers
```

- Now clients can be configured to connect to the cluster. For an example, see the following code in the [examples](https://github.com/hashicorp/terraform-azure-consul-ent-starter/tree/main/examples/vm_client) directory.

## License

This code is released under the Mozilla Public License 2.0. Please see
[LICENSE](https://github.com/hashicorp/terraform-azure-consul-ent-starter/tree/main/LICENSE) for more details.
