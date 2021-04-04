resource "tls_private_key" "ssh" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "local_file" "ssh_private_key" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "${path.module}/private.pem"
  file_permission = "0600"
}

resource "oci_core_instance" "instance" {
  availability_domain = "gHLA:US-SANJOSE-1-AD-1" # TODO
  compartment_id      = var.compartment_id
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
  compartment_id = var.compartment_id
}

resource "oci_core_subnet" "subnet" {
  cidr_block     = var.subnet_cidr_block
  compartment_id = var.compartment_id
  route_table_id = oci_core_vcn.vcn.default_route_table_id
  vcn_id         = oci_core_vcn.vcn.id
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
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command     = "ansible-playbook -u ubuntu -i ${oci_core_instance.instance.public_ip}, --private-key ${local_file.ssh_private_key.filename} ${path.module}/../ansible/main.yml"
    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
    }
  }
}
