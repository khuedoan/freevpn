terraform {
  required_providers {
    oci = {
      source  = "hashicorp/oci"
      version = "4.20.0"
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
