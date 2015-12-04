#!/bin/bash
LOCAL_DEPLOY=""
PLAN_ONLY=""
APPLY_SEPARATE=false
ATTRIBUTES=""

while [[ $# > 0 ]]
do
  key="$1"
  case $key in
    --attributes)
      ATTRIBUTES="-e extra_slave_attributes=$2"
      shift
    ;;
    --plan_only)
      PLAN_ONLY="-e terraform_plan_only=true"
    ;;
    --apply_separate)
      APPLY_SEPARATE=true
      PLAN_ONLY="-e terraform_plan_only=true"
    ;;
    --local_deploy)
      LOCAL_DEPLOY="-e local_slave_deploy=true"
    ;;
    *)
      CLUSTER_NAME="$key"
    ;;
  esac
  shift
done

source setup_amazon_env.bash $CLUSTER_NAME

echo "WILL RUN COMMAND:"
echo ansible-playbook -i inventory/terraform.py -v --private-key cluster_vars/$CLUSTER_NAME/${CLUSTER_NAME}_key.pem manage_terraform_playbook.yml \
-e cluster_name=$CLUSTER_NAME $PLAN_ONLY $LOCAL_DEPLOY $ATTRIBUTES
time -f "wall time to run playbook:%e" \
ansible-playbook -i inventory/terraform.py -v --private-key cluster_vars/$CLUSTER_NAME/${CLUSTER_NAME}_key.pem manage_terraform_playbook.yml \
-e cluster_name=$CLUSTER_NAME $PLAN_ONLY $LOCAL_DEPLOY $ATTRIBUTES

if [ $? -ne 0 ] ; then
  echo "OOPS $?"
  exit $?
fi

if [ "$APPLY_SEPARATE" == "true" ] ; then
  cd terraform/$CLUSTER_NAME
  /usr/bin/time -f "wall time to run terraform:%e" terraform apply
fi
