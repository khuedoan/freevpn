output "instance_public_ip" {
  value = oci_core_public_ip.public_ip.ip_address
}
