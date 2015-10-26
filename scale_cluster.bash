#!/bin/bash
LOCAL_DEPLOY=false
PLAN_ONLY=false
APPLY_SEPARATE=false
while [[ $# > 0 ]]
do
  key="$1"
  case $key in
    --plan_only)
      PLAN_ONLY=true
    ;;
    --apply_separate)
      APPLY_SEPARATE=true
    ;;
    --local_deploy)
      LOCAL_DEPLOY=true
    ;;
    *)
      CLUSTER_NAME=$key
    ;;
  esac
  shift
done

source setup_amazon_env.bash $CLUSTER_NAME
if [ -z "$PLAN_ONLY" ] && [ -z "APPLY_SEPARATE" ] ; then
    ansible-playbook --private-key cluster_vars/$CLUSTER_NAME/${CLUSTER_NAME}_key.pemmanage_terraform_playbook.yml -e "cluster_name=$CLUSTER_NAME" -e "local_slave_deploy=$LOCAL_DEPLOY"
else
    ansible-playbook --private-key cluster_vars/$CLUSTER_NAME/${CLUSTER_NAME}_key.pem manage_terraform_playbook.yml -e "cluster_name=$CLUSTER_NAME" -e "local_slave_deploy=$LOCAL_DEPLOY" -e "terraform_plan_only=true"
fi

if [ "$APPLY_SEPARATE" == "true" ] ; then
  cd terraform/$CLUSTER_NAME
  terraform apply
fi