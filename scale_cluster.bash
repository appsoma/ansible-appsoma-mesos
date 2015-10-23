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
    ansible-playbook -v --private-key cluster_vars/$CLUSTER_NAME/${CLUSTER_NAME}_key.pem -i inventory/terraform.py manage_terraform_playbook.yml -e "cluster_name=$CLUSTER_NAME" -e "local_slave_deploy=$LOCAL_DEPLOY"
else
    ansible-playbook -v --private-key cluster_vars/$CLUSTER_NAME/${CLUSTER_NAME}_key.pem -i inventory/terraform.py manage_terraform_playbook.yml -e "cluster_name=$CLUSTER_NAME" -e "local_slave_deploy=$LOCAL_DEPLOY" -e "terraform_plan_only=true"
fi

