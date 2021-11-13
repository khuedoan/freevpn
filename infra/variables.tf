variable "tenancy_id" {}
variable "user_id" {}
variable "fingerprint" {}
variable "region" {}
variable "private_key" {}

variable "vcn_cidr_blocks" {
  default = [
    "10.0.0.0/16"
  ]
}

variable "subnet_cidr_block" {
  default = "10.0.0.0/24"
}

variable "instance_shape" {
  default = "VM.Standard.E2.1.Micro"
}
