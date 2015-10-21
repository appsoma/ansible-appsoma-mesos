#!/bin/bash
while [[ $# > 0 ]]
do
  key="$1"
  case $key in
    --plan_only)
      PLAN_ONLY="true"
    ;;
    --local_deploy)
      LOCAL_DEPLOY="true"
    ;;
    *)
      CLUSTER_NAME=$key
    ;;
  esac
  shift
done

source setup_amazon_env.bash $CLUSTER_NAME
if [ -z "$PLAN_ONLY" ] ; then
    echo ansible-playbook -v --private-key cluster_vars/$1/${1}_key.pem -i inventory/terraform.py manage_terraform_playbook.yml -e "cluster_name=$1" -e "local_slave_deploy=$LOCAL_DEPLOY"
else
    echo ansible-playbook -v --private-key cluster_vars/$1/${1}_key.pem -i inventory/terraform.py manage_terraform_playbook.yml -e "cluster_name=$1" -e "local_slave_deploy=$LOCAL_DEPLOY" -e "terraform_plan_only=true"
fi

