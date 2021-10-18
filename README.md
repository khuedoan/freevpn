# VPN

Deprecated in favor of the [freecloud](https://github.com/khuedoan/freecloud) project.

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

## Provision

Change your backend config in [./terraform.tf](./terraform.tf#L2) (or you can remove that block and use local backend), then apply:

```sh
terraform init
terraform apply
```

## Usage

Get QR code for mobile:

```sh
ssh -i ./private.pem ubuntu@$OUTPUT_IP sudo docker exec wireguard /app/show-peer phone
```

Get config for Linux laptop:

```sh
ssh -i private.pem ubuntu@$OUTPUT_IP sudo cat /etc/wireguard/peer_laptop/peer_laptop.conf > wg0.conf
nmcli connection import type wireguard file wg0.conf
nmcli connection up wg0
```
