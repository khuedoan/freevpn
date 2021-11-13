variable "instance_shape" {
  default = "VM.Standard.E2.1.Micro"
}

variable "compartment_id" {

}

variable "user_ocid" {}
variable "tenancy_ocid" {}
variable "fingerprint" {}
variable "region" {}
variable "private_key" {}

variable "image" {
  description = "OS image properties"

  type = object({
    operating_system = string
    version          = string
  })

  default = {
    operating_system = "Canonical Ubuntu"
    version          = "20.04 Minimal"
  }
}

variable "vcn_cidr_blocks" {
  default = [
    "10.0.0.0/16"
  ]
}

variable "subnet_cidr_block" {
  default = "10.0.0.0/24"
}
