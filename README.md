# Edge

Create an always free WireGuard VPN and HAProxy on Oracle Cloud using Terraform and Ansible

## Architecture

```
                                          ┌───────────────────────────────────┐
                                          │           Homelab network         │
                                          ├───────────────────────────────────┤
                                          │                                   │
                                          │                     ┌───────────┐ │
                                          │                     │           │ │
┌──────────────────────────────┐          │          ┌─────────►│ Service 1 │ │
│         Oracle Cloud         │          │          │          │           │ │
├──────────────────────────────┤          │          │          └───────────┘ │
│                              │          │          │                        │
│ ┌─────────┐    ┌───────────┐ │      ┌───┴────┐     │          ┌───────────┐ │
│ │         │    │           │ │      │        │     │          │           │ │
│ │ HAProxy ├───►│ Wireguard ├─┼──────┤ Router ├─────┼─────────►│ Service 2 │ │
│ │         │    │           │ │      │        │     │          │           │ │
│ └─────────┘    └───────────┘ │      └───┬────┘     │          └───────────┘ │
│                              │          │          │                        │
└──────────────────────────────┘          │          │          ┌───────────┐ │
                                          │          │          │           │ │
                                          │          └─────────►│ Service 3 │ │
                                          │                     │           │ │
                                          │                     └───────────┘ │
                                          │                                   │
                                          └───────────────────────────────────┘
```

## Prerequisites

- Create an Oracle Cloud account
- Generate an API signing key:
  - Profile menu (User menu icon) -> User Settings -> API Keys -> Add API Key
  - Select Generate API Key Pair, download the private key to `~/.oci/oci_api_key.pem` and click Add
  - Copy the Configuration File Preview and put it in `~/.oci/config`

The config file should look something like this:

```ini
[DEFAULT]
user=ocid1.user.oc1..aaaxxx
fingerprint=xx:xx:xx
tenancy=ocid1.tenancy.oc1..aaaxxx
region=xxx
key_file=~/.oci/oci_api_key.pem
```
