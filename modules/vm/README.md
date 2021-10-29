# Azure VM Module

## Required Variables

* `application_security_group_ids` - List of application security groups to which the VMs' network interfaces will be associated
* `health_check_path` - HTTP path for Azure VM health check
* `identity_ids` - List of user assigned identities to apply to the VMs
* `instance_count` - Number of virtual machines to maintain in the scale set
* `resource_group` - Resource group in which resources will be deployed
* `resource_name_prefix` - Prefix placed before resource names
* `scale_set_name` - Name for virtual machine scale set
* `ssh_public_key` - Public key permitted to access the VMs (as `azureuser` by default)
* `subnet_id` - Subnet in which the VMs will be deployed
* `user_data` - User data for virtual machine configuration

## Example Usage

```hcl
module "vm" {
  source = "./modules/vm"

  health_check_path    = "/v1/status/leader"
  instance_count       = 5
  resource_name_prefix = "dev"
  scale_set_name       = "dev-consul-servers"
  ssh_public_key       = "ssh-rsa AAAAB3NzaC1yc2EAAAADA..."
  subnet_id            = "/subscriptions/.../resourceGroups/myresourcegroupname/providers/Microsoft.Network/virtualNetworks/myvnetname/subnets/myconsulsubnetname"
  user_data            = base64encode("#!/bin/bash\necho 'starting setup'\n...")

  application_security_group_ids = [
    "/subscriptions/.../resourceGroups/myresourcegroupname/providers/Microsoft.Network/applicationSecurityGroups/dev-consul-ingress",
    ...
  ]

  identity_ids = [
    "/subscriptions/.../resourceGroups/myresourcegroupname/providers/Microsoft.ManagedIdentity/userAssignedIdentities/dev-consul-server",
  ]

  resource_group = {
    location = "eastus"
    name     = "myresourcegroupname"
  }
}
```
