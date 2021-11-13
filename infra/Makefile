.POSIX:

default: .terraform apply

.terraform:
	terraform init

apply:
	terraform apply -auto-approve

private.pem: .terraform
	terraform show -json \
		| jq --raw-output '.values.root_module.resources[] | select(.address == "tls_private_key.ssh") | .values.private_key_pem' \
		> private.pem
	chmod 600 private.pem
