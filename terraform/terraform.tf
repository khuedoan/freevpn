terraform {
  backend "remote" {
    organization = "khuedoan"

    workspaces {
      name = "homelab-edge"
    }
  }

  required_providers {
    oci = {
      source = "hashicorp/oci"
      version = "4.16.0"
    }
  }
}

provider "oci" {
  tenancy_ocid = var.tenancy_ocid
  user_ocid = var.user_ocid
  fingerprint = var.fingerprint
  private_key_path = var.private_key_path
  region = var.region
}
