variable "instance_shape" {
  default = "VM.Standard.E2.1.Micro"
}

variable "compartment_id" {}
variable "user_ocid" {}
variable "tenancy_ocid" {}
variable "fingerprint" {}
variable "region" {}
variable "private_key" {}

variable "instance_image_id" {
  # check https://docs.oracle.com/en-us/iaas/images/image/1ae1a20e-0f60-442e-b68f-cb9460ab2106/
  default = "ocid1.image.oc1.ap-osaka-1.aaaaaaaavbtmrf6kcgh4dsewl7fsjlwcjkdwaeiqalsstjgb4ipnqeveo6da"
}

variable "vcn_cidr_blocks" {
  default = [
    "10.0.0.0/16"
  ]
}

variable "subnet_cidr_block" {
  default = "10.0.0.0/24"
}
