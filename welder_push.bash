#!/usr/bin/env bash
if [ "$1" == "" ] || [ "$2" == "" ]; then
	echo "USAGE: welder_push.bash BRANCH CLUSTER"
	exit 1
fi
BRANCH=$1
CLUSTER=$2
echo "PUSHING WELDER BRANCH $BRANCH to CLUSTER $CLUSTER"
ansible-playbook --private-key ~/vmmy.pem -i inventory/ec2.py playbooks/welder_playbook.yml -e "welder_version=$BRANCH cluster_name=$CLUSTER"
