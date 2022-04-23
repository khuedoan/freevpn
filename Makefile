.POSIX:
.SILENT:
.PHONY: infra config

default: infra config

infra:
	make -C infra

config:
	make -C infra private.pem
	make -C config

qr:
	ssh -i ./infra/private.pem \
		ubuntu@$(shell cd ./infra && terraform output -raw instance_public_ip) \
		sudo docker exec wireguard /app/show-peer phone

nmconf:
	ssh -i ./infra/private.pem \
		ubuntu@$(shell cd ./infra && terraform output -raw instance_public_ip) \
		sudo cat /etc/wireguard/peer_laptop/peer_laptop.conf
