#!/bin/bash
source setup_amazon_env.bash $1
/usr/bin/time -f "wall time to run playbook:%e" \
ansible-playbook --private-key cluster_vars/$1/${1}_key.pem -i inventory/terraform.py $2 -e "cluster_name=$1"
