#!/usr/bin/env bash
set -e -o pipefail

# install package
curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-releases-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-releases-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" > /etc/apt/sources.list.d/hashicorp-releases.list
apt-get update
apt-get install -y python3-pip consul-enterprise=${consul_version}+ent jq

# install azure-cli
# the azure-cli package in Ubuntu universe repo would be ideal, but it is broken in the Ubuntu 20.04 universe repo
# https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt#overview
# instead, it is installed here via pypi (by way of the python3-pip package installed above)
pip3 install --no-warn-script-location --user 'azure-cli~=2.26.0' 'azure-mgmt-core~=1.2.0' 'cryptography~=3.3.2' 'urllib3[secure]~=1.26.5' 'requests~=2.25.1'

# configuring Azure CLI for use with VM managed identity
~/.local/bin/az login --identity --username "${client_id}"

echo "Configuring system time"
timedatectl set-timezone UTC

# removing any default installation files from /opt/consul/tls/
rm -rf /opt/consul/tls/*

# /opt/consul/tls should be readable by all users of the system
mkdir /opt/consul/tls
chmod 0755 /opt/consul/tls

printf "%s" "${ca_cert}" > /opt/consul/tls/consul-ca.pem

~/.local/bin/az keyvault secret show --id "${license_secret_id}" --query "value" --output tsv | base64 -d > /opt/consul/consul.hclic
# consul.hclic should be readable by the consul group only
chown root:consul /opt/consul/consul.hclic
chmod 0640 /opt/consul/consul.hclic

gossip_encryption_key=$(~/.local/bin/az keyvault secret show --id "${gossip_secret_id}" --query "value" --output tsv)

# Switch CLI login to app identity
~/.local/bin/az login --identity --username "${app_identity_client_id}"

# Deploy Consul config
%{ if acl_tokens_secret_id != null }acl_tokens=$(~/.local/bin/az keyvault secret show --id "${acl_tokens_secret_id}" --query "value" --output tsv)%{ endif }
cat << EOF > /etc/consul.d/consul.hcl
ca_file                = "/opt/consul/tls/consul-ca.pem"
data_dir               = "/opt/consul/data"
encrypt                = "$gossip_encryption_key"
license_path           = "/opt/consul/consul.hclic"
server                 = false
verify_incoming        = true
verify_outgoing        = true
verify_server_hostname = true

retry_join = [
  "provider=azure subscription_id=${subscription_id} resource_group=${resource_group_name} vm_scale_set=${server_scale_set_name}",
]

acl = {
  enabled = true
  default_policy = "deny"
  enable_token_persistence = true
%{ if acl_tokens_secret_id != null }
  tokens {
    $acl_tokens
  }
%{ endif }
}

auto_encrypt = {
  tls = true
}

ports {
  https = 8501
}
EOF

# Configure Consul's use of shared managed identity
echo "AZURE_CLIENT_ID=${client_id}" >> /etc/consul.d/consul.env

# consul.hcl should be readable by the consul group only
chown root:root /etc/consul.d
chown root:consul /etc/consul.d/consul.hcl
chmod 640 /etc/consul.d/consul.hcl

systemctl enable consul
systemctl start consul

# Consul configuration complete - add your application configuration starting here

# Note: the VM's managed identity has access to the Consul gossip encryption key
# (for the consul.hcl configuration above)
# If your application does not require access to its own Azure Managed Identity,
# consider disabling non-root access to the Azure Instance Metadata Service (e.g. via iptables)
