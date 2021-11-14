resource "tls_private_key" "ssh" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "oci_identity_compartment" "vpn" {
  compartment_id = var.tenancy_id
  name           = "vpn"
  description    = "VPN"
}

data "oci_identity_availability_domains" "availability_domains" {
  compartment_id = oci_identity_compartment.vpn.id
}

data "oci_core_images" "image" {
  compartment_id           = oci_identity_compartment.vpn.id
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "20.04 Minimal"
  shape                    = var.instance_shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

resource "oci_core_instance" "instance" {
  availability_domain = data.oci_identity_availability_domains.availability_domains.availability_domains[0].name
  compartment_id      = oci_identity_compartment.vpn.id
  shape               = var.instance_shape

  instance_options {
    are_legacy_imds_endpoints_disabled = true
  }

  create_vnic_details {
    assign_public_ip = "true"
    subnet_id        = oci_core_subnet.subnet.id
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.image.images[0].id
  }

  metadata = {
    ssh_authorized_keys = tls_private_key.ssh.public_key_openssh
  }

  lifecycle {
    ignore_changes = [
      source_details # forces replacement
    ]
  }
}

resource "oci_core_vcn" "vcn" {
  cidr_blocks    = var.vcn_cidr_blocks
  compartment_id = oci_identity_compartment.vpn.id
}

resource "oci_core_security_list" "security_list" {
  compartment_id = oci_identity_compartment.vpn.id
  vcn_id         = oci_core_vcn.vcn.id

  ingress_security_rules {
    description = "Wireguard"
    protocol    = "17" # UDP
    source      = "0.0.0.0/0"
    stateless   = false

    udp_options {
      source_port_range {
        min = 1
        max = 65535
      }

      min = 51820
      max = 51820
    }
  }

  ingress_security_rules {
    description = "HTTP"
    protocol    = "6" # TCP
    source      = "0.0.0.0/0"
    stateless   = false

    tcp_options {
      source_port_range {
        min = 1
        max = 65535
      }

      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    description = "HTTPS"
    protocol    = "6" # TCP
    source      = "0.0.0.0/0"
    stateless   = false

    tcp_options {
      source_port_range {
        min = 1
        max = 65535
      }

      min = 443
      max = 443
    }
  }
}

resource "oci_core_subnet" "subnet" {
  cidr_block     = var.subnet_cidr_block
  compartment_id = oci_identity_compartment.vpn.id
  route_table_id = oci_core_vcn.vcn.default_route_table_id
  vcn_id         = oci_core_vcn.vcn.id

  security_list_ids = [
    oci_core_vcn.vcn.default_security_list_id,
    oci_core_security_list.security_list.id
  ]
}

resource "oci_core_internet_gateway" "internet_gateway" {
  compartment_id = oci_identity_compartment.vpn.id
  vcn_id         = oci_core_vcn.vcn.id
}

resource "oci_core_default_route_table" "default_route_table" {
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.internet_gateway.id
  }
  manage_default_resource_id = oci_core_vcn.vcn.default_route_table_id
}
