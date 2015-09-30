#!/bin/bash
source setup_amazon_env.bash $1
ansible-playbook --private-key cluster_vars/$1/${1}_key.pem -i inventory/terraform.py manage_terraform_playbook.yml -e "cluster_name=$1"
ansible-playbook --private-key cluster_vars/$1/${1}_key.pem -i inventory/terraform.py $2 -e "cluster_name=$1"
