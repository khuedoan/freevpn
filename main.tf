resource "tls_private_key" "ssh" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "local_file" "ssh_private_key" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "${path.module}/private.pem"
  file_permission = "0600"
}

resource "oci_identity_compartment" "vpn" {
  compartment_id = var.tenancy_ocid
  name           = "vpn"
  description    = "VPN"
}

data "oci_identity_availability_domains" "availability_domains" {
  compartment_id = oci_identity_compartment.vpn.id
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
    source_id   = var.instance_image_id
  }

  metadata = {
    ssh_authorized_keys = tls_private_key.ssh.public_key_openssh
    user_data           = filebase64("${path.module}/cloud-init.yaml")
  }
}

resource "oci_core_vcn" "vcn" {
  cidr_block     = var.vcn_cidr_blocks[0] # TODO deprecated, use cidr_blocks instead
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

resource "null_resource" "ansible" {
  triggers = {
    ansible_hash = md5(join("", [for f in fileset("${path.module}/ansible/", "**"): file("${path.module}/ansible/${f}")]))
  }

  provisioner "local-exec" {
    command = "ansible-playbook -u ubuntu -i ${oci_core_instance.instance.public_ip}, --private-key ${local_file.ssh_private_key.filename} ${path.module}/ansible/main.yml"

    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
    }
  }
}
