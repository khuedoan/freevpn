resource "oci_core_instance" "instance" {
	availability_domain = "gHLA:US-SANJOSE-1-AD-1"
	compartment_id = var.compartment_id
	create_vnic_details {
		assign_public_ip = "true"
		subnet_id = oci_core_subnet.subnet.id
	}
	instance_options {
		are_legacy_imds_endpoints_disabled = true
	}
	metadata = {
		ssh_authorized_keys = var.ssh_public_key
    user_data = ""
	}
	shape = var.instance_shape
	source_details {
		source_type = "image"
		source_id = var.instance_image_id
	}
}

resource "oci_core_vcn" "vcn" {
	cidr_blocks = var.vcn_cidr_blocks
	compartment_id = var.compartment_id
}

resource "oci_core_subnet" "subnet" {
	cidr_block = var.subnet_cidr_block
	compartment_id = var.compartment_id
	route_table_id = oci_core_vcn.vcn.default_route_table_id
	vcn_id = oci_core_vcn.vcn.id
}

resource "oci_core_internet_gateway" "internet_gateway" {
	compartment_id = var.compartment_id
	vcn_id = oci_core_vcn.vcn.id
}

resource "oci_core_default_route_table" "default_route_table" {
	route_rules {
		destination = "0.0.0.0/0"
		destination_type = "CIDR_BLOCK"
		network_entity_id = oci_core_internet_gateway.internet_gateway.id
	}
	manage_default_resource_id = oci_core_vcn.vcn.default_route_table_id
}
