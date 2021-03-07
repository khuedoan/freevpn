resource "oci_core_instance" "generated_oci_core_instance" {
	agent_config {
		is_management_disabled = "false"
		is_monitoring_disabled = "false"
		plugins_config {
			desired_state = "ENABLED"
			name = "Compute Instance Monitoring"
		}
	}
	availability_config {
		recovery_action = "RESTORE_INSTANCE"
	}
	availability_domain = "gHLA:US-SANJOSE-1-AD-1"
	compartment_id = "ocid1.tenancy.oc1..aaaaaaaavge5xuefgatecpqozjzpux5getu6o4s5wzdwduv36pur63fxoxua"
	create_vnic_details {
		assign_public_ip = "true"
		subnet_id = "${oci_core_subnet.generated_oci_core_subnet.id}"
	}
	display_name = "instance-20210307-1223"
	instance_options {
		are_legacy_imds_endpoints_disabled = "false"
	}
	metadata = {
		"ssh_authorized_keys" = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDIziitFdMykep1YPE+ltWDeL63DDsqVsBWe02qVNlNJJAm8JbLdDK98p1LgaqVMnQoo/YLdL2EsAsgu1cgojlwrty/qUIvBHfF+woxo/DyJQqlNvpuSkCtmjShXOj8ORywAFoQlEENWExMcRQbgQw9dSaTXEzHmR7h0b9Mn1k9LnI5iXG3Oy2wFsSRWb8qxN6lNNaOwY1/RZGw4LeBPve0iaZoOJ3/RXQhRk1seJgL7pNcOQOhUO/h78CGfUqF3pXusg0YNk7leDBkKK724whMeDbxy8cRRN69wMktPj4ZYXB6yi2DRIldc3pka3yn/cU0s9JNXgXTw95TtA+W0PxWHiifz+YYu6f5AYyyWgwhaGUDsRRy/xPfHPn58bc1Adk3XNkqL7f7m+/TrpJdhCToOWStyFy5GwTum9gOUgSCyvCg6pUgTlENMSyecjmlVK+ZD+d5xhZa9LdMQ/CY324gTj/iTmpOKDe7NDZFrEsqA3FDFfG2uhaXkHMrt88AgaQuMCGPDmvMwJlHRivAacFgO8ues7l/z6kbr5yyh0RnNfY7dOthtBOyuG13cGIsmSJTP7zKJ6kVIm/z+5IZk1hcPy33QgRgA522N9gG8o3iKY5cPQqzwkJkM9aWmqb3uLA3WVZ9krs4HEGHYDZJO67+F9lTaDX6rjJbetOUoYQvVw=="
	}
	shape = "VM.Standard.E2.1.Micro"
	source_details {
		source_id = "ocid1.image.oc1.us-sanjose-1.aaaaaaaan4g4q527bljtyczck6xrsutbzps6h7mut2xcfhnbzw66sbbsvwoq"
		source_type = "image"
	}
}

resource "oci_core_vcn" "generated_oci_core_vcn" {
	cidr_block = "10.0.0.0/16"
	compartment_id = "ocid1.tenancy.oc1..aaaaaaaavge5xuefgatecpqozjzpux5getu6o4s5wzdwduv36pur63fxoxua"
	display_name = "vcn-20210307-1223"
	dns_label = "vcn03071225"
}

resource "oci_core_subnet" "generated_oci_core_subnet" {
	cidr_block = "10.0.0.0/24"
	compartment_id = "ocid1.tenancy.oc1..aaaaaaaavge5xuefgatecpqozjzpux5getu6o4s5wzdwduv36pur63fxoxua"
	display_name = "subnet-20210307-1223"
	dns_label = "subnet03071225"
	route_table_id = "${oci_core_vcn.generated_oci_core_vcn.default_route_table_id}"
	vcn_id = "${oci_core_vcn.generated_oci_core_vcn.id}"
}

resource "oci_core_internet_gateway" "generated_oci_core_internet_gateway" {
	compartment_id = "ocid1.tenancy.oc1..aaaaaaaavge5xuefgatecpqozjzpux5getu6o4s5wzdwduv36pur63fxoxua"
	display_name = "Internet Gateway vcn-20210307-1223"
	enabled = "true"
	vcn_id = "${oci_core_vcn.generated_oci_core_vcn.id}"
}

resource "oci_core_default_route_table" "generated_oci_core_default_route_table" {
	route_rules {
		destination = "0.0.0.0/0"
		destination_type = "CIDR_BLOCK"
		network_entity_id = "${oci_core_internet_gateway.generated_oci_core_internet_gateway.id}"
	}
	manage_default_resource_id = "${oci_core_vcn.generated_oci_core_vcn.default_route_table_id}"
}
