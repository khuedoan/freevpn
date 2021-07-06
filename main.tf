resource "tls_private_key" "ssh" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "local_file" "ssh_private_key" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "${path.module}/private.pem"
  file_permission = "0600"
}

resource "local_file" "ssh_public_key" {
  content         = tls_private_key.ssh.public_key_openssh
  filename        = "${path.module}/public.pem"
  file_permission = "0600"
}

# Get a list of Availability Domains
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

# Output the result
output "show-ads" {
  value = data.oci_identity_availability_domains.ads.availability_domains
}

resource "oci_core_instance" "instance" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name # TODO
  compartment_id      = var.compartment_id
  shape               = var.instance_shape
  display_name        = "Ubuntu - US - VPN"

  create_vnic_details {
    assign_public_ip       = "true"
    subnet_id              = oci_core_subnet.subnet.id
    skip_source_dest_check = "true"
  }

  source_details {
    source_type = "image"
    source_id   = var.instance_image_id
  }

  metadata = {
    ssh_authorized_keys = tls_private_key.ssh.public_key_openssh
    # ssh_authorized_keys = file("/Users/svphan/.ssh/id_rsa.pub")
  }
}

resource "oci_core_vcn" "vcn" {
  cidr_block     = var.vcn_cidr_blocks[0] # TODO deprecated, use cidr_blocks instead
  compartment_id = var.compartment_id
}

resource "oci_core_security_list" "security_list" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id

  ingress_security_rules {
    description = "SSH"
    protocol    = "6" # TCP
    source      = "0.0.0.0/0"
    stateless   = false

    tcp_options {
      min = 22
      max = 22
    }
  }

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

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }
}

resource "oci_core_subnet" "subnet" {
  cidr_block     = var.subnet_cidr_block
  compartment_id = var.compartment_id
  route_table_id = oci_core_vcn.vcn.default_route_table_id
  vcn_id         = oci_core_vcn.vcn.id

  security_list_ids = [
    oci_core_security_list.security_list.id
  ]
}

resource "oci_core_internet_gateway" "internet_gateway" {
  compartment_id = var.compartment_id
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
    command = "ansible-playbook -u ubuntu -i ${oci_core_instance.instance.public_ip}, --private-key ${local_file.ssh_private_key.filename} ${path.module}/ansible/main.yml -v"

    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
    }
  }

  provisioner "local-exec" {
    command = "ansible-playbook -u ubuntu -i ${oci_core_instance.instance.public_ip}, --private-key ${local_file.ssh_private_key.filename} ${path.module}/ansible/getconfig.yml -v"

    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
    }
  }
}
