#!/bin/bash
VAR_DIR=${PWD}/cluster_vars
if [ "$1" == "--vars" ]; then
    shift
  	VAR_DIR=${1}
  	shift
fi
echo "Running update/deploy from container with args: $@"
docker run -it --rm --name appsoma-software-deploy -v ${VAR_DIR}/terraform:/ansible-appsoma-mesos/terraform -v ${VAR_DIR}:/ansible-appsoma-mesos/cluster_vars appsoma/ansible-appsoma-mesos ./update_cluster.bash $@
exit $?

