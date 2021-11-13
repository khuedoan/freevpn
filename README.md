# VPN

Create an always free WireGuard VPN server on Oracle Cloud using Terraform and Ansible.

## Prerequisites

- Install the following packages:
  - `terraform`
  - `ansible`
- Create a Terraform backend (I'm using [Terraform Cloud](https://app.terraform.io))
- Create an Oracle Cloud account
- Generate an API signing key:
  - Profile menu (User menu icon) -> User Settings -> API Keys -> Add API Key
  - Select Generate API Key Pair, download the private key and click Add
  - Check the Configuration File Preview for the values

Put those values in `./terraform.auto.tfvars`:

```ini
user_ocid = "ocid1.user.xxx"
fingerprint = "xx:xx:xx"
tenancy_ocid = "ocid1.tenancy.xxx"
region = "us-xxx"
compartment_id = "ocid1.tenancy.xxx" # likely the same as tenancy_ocid
private_key = <<EOT
-----BEGIN PRIVATE KEY-----
xxx (from the downloaded private key)
-----END PRIVATE KEY-----
EOT
```

## Get started

### Create the VM

Change your backend config in [./infra/versions.tf](./terraform.tf#L5) (or you can remove that block and use local backend), then apply:

```sh
cd infra
terraform init
terraform apply
cd ..
```

Note the IP address in output.

### Configure the VM

```sh
cd config
ansible-playbook -u ubuntu -i ${IP_ADDRESS}, --private-key private.pem main.yml
```

## Usage

Get SSH key:

```sh
cd infra
terraform init
terraform show -json | jq --raw-output '.values.root_module.resources[] | select(.address == "tls_private_key.ssh") | .values.private_key_pem' > private.pem
chmod 600 private.pem
```

Get QR code for mobile:

```sh
ssh -i ./private.pem ubuntu@${IP_ADDRESS} sudo docker exec wireguard /app/show-peer phone
```

Get config for Linux laptop:

```sh
ssh -i private.pem ubuntu@${IP_ADDRESS} sudo cat /etc/wireguard/peer_laptop/peer_laptop.conf > wg0.conf
nmcli connection import type wireguard file wg0.conf
nmcli connection up wg0
```
