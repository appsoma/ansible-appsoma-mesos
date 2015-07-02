#!/bin/bash
source setup_amazon_env.bash $1
ansible-playbook --private-key cluster_vars/$1/${1}_key.pem -i inventory/ec2Inventory.py $2 -e "cluster_name=$1"
