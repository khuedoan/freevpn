# Set up without Terraform
1. Create Oracle Free tier Ubuntu instance with your SSH public key
2. Set up security network group to allow 51820 UDP from 0.0.0.0/0
3. Update ansible variables and run
```
ansible-galaxy install -p roles -r requirements.yml
ansible-playbook -u ubuntu -i [instance_public_ip], main.yml
ansible-playbook -u ubuntu -i [instance_public_ip], getconfig.yml
```