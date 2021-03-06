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
}
