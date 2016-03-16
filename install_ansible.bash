#!/usr/bin/env bash
sudo pip install ansible

if [ -z "$1" ]; then
if [ "$1" != "local" ]; then
TF_VERSION=0.6.6
wget https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip -O terraform_${TF_VERSION}.zip
unzip terraform_${TF_VERSION}.zip -d terraform_${TF_VERSION}
sudo cp -P terraform_${TF_VERSION}/terraform /usr/local/bin
sudo cp -P terraform_${TF_VERSION}/terraform-provider-aws /usr/local/bin
sudo cp -P terraform_${TF_VERSION}/terraform-provider-google /usr/local/bin
sudo cp -P terraform_${TF_VERSION}/terraform-provider-openstack /usr/local/bin
sudo cp -P terraform_${TF_VERSION}/terraform-provisioner-local-exec /usr/local/bin
sudo cp -P terraform_${TF_VERSION}/terraform-provisioner-file /usr/local/bin
sudo cp -P terraform_${TF_VERSION}/terraform-provisioner-remote-exec /usr/local/bin
fi
fi
