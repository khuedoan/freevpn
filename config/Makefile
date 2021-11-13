.POSIX:

IP_ADDRESS=$

apply:
	ansible-playbook \
		--user ubuntu \
		--inventory $(shell cd ../infra && terraform output -raw instance_public_ip), \
		--private-key ../infra/private.pem \
		main.yml
