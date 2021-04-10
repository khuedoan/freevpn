# Edge

Create an always free edge node with WireGuard and HAProxy on Oracle Cloud using Terraform and Ansible.
This is useful if you can't port forward because you don't have access to the router admin settings or you have double NAT.

## Architecture

```
                                                   ┌─────────────────────────┐
                                                   │         Homelab         │
                                                   ├─────────────────────────┤
          ┌────────────────────────────────┐       │           ┌───────────┐ │
          │          Oracle Cloud          │       │       ┌──►│ Service 1 │ │
          ├────────────────────────────────┤       │       │   └───────────┘ │
┌──────┐  │   ┌─────────┐   ┌───────────┐  │   ┌───┴────┐  │   ┌───────────┐ │
│ User ├──┼──►│ HAProxy ├──►│ Wireguard ├──┼──►│ Router ├──┼──►│ Service 2 │ │
└──────┘  │   └─────────┘   └───────────┘  │   └───┬────┘  │   └───────────┘ │
          └────────────────────────────────┘       │       │   ┌───────────┐ │
                                                   │       └──►│ Service 3 │ │
                                                   │           └───────────┘ │
                                                   └─────────────────────────┘
```

## Prerequisites

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

## Usage

Get QR code:

```sh
ssh -i ./private.pem ubuntu@$OUTPUT_IP sudo docker exec wireguard /app/show-peer 1
```
