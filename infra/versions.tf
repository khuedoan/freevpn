terraform {
  required_version = "~> 1.0.0"

  backend "remote" {
    organization = "khuedoan"

    workspaces {
      name = "vpn"
    }
  }

  required_providers {
    oci = {
      source  = "hashicorp/oci"
      version = "~> 4.52.0"
    }
  }
}

provider "oci" {
  user_ocid    = var.user_ocid
  fingerprint  = var.fingerprint
  tenancy_ocid = var.tenancy_ocid
  region       = var.region
  private_key  = var.private_key
}
