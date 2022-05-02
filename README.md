# Free VPN

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

Put those values in `./infra/terraform.tfvars`:

```hcl
user_id = "ocid1.user.xxx"
fingerprint = "xx:xx:xx"
tenancy_id = "ocid1.tenancy.xxx"
region = "us-xxx"
private_key = <<EOT
-----BEGIN PRIVATE KEY-----
xxx (from the downloaded private key)
-----END PRIVATE KEY-----
EOT
```

## Get started

### Provision

Change your backend config in [`./infra/versions.tf`](./infra/versions.tf#L5) (or you can remove that block and use local backend), then run:

```sh
make
```

Note the IP address in output.

## Usage

Get QR code for mobile:

```sh
make qr
```

Get config for Linux laptop:

```sh
make nmconf > wg0.conf
nmcli connection import type wireguard file wg0.conf
nmcli connection up wg0
```

Get SSH key:

```sh
make -C infra private.pem
```
