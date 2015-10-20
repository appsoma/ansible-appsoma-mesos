#!/bin/bash
source setup_amazon_env.bash $1
if [ -z "$2" ] ; then
   plan="false"
else
   plan="true"
fi
ansible-playbook -v --private-key cluster_vars/$1/${1}_key.pem -i inventory/terraform.py manage_terraform_playbook.yml -e "cluster_name=$1" -e "terraform_plan_only=$plan"

