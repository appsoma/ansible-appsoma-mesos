#!/usr/bin/env bash
sudo apt-get install -y software-properties-common
sudo apt-add-repository -y ppa:ansible/ansible
sudo apt-get update
sudo apt-get install -y ansible unzip

if [ -z "$1" ]; then
if [ "$1" != "local" ]; then
TF_VERSION=0.6.6
wget https://dl.bintray.com/mitchellh/terraform/terraform_$TF_VERSION_linux_amd64.zip -O terraform_$TF_VERSION.zip
unzip terraform_$TF_VERSION.zip -d terraform_$TF_VERSION
sudo cp -P terraform_$TF_VERSION/terraform /usr/local/bin
sudo cp -P terraform_$TF_VERSION/terraform-provider-aws /usr/local/bin
sudo cp -P terraform_$TF_VERSION/terraform-provider-google /usr/local/bin
sudo cp -P terraform_$TF_VERSION/terraform-provider-openstack /usr/local/bin
sudo cp -P terraform_$TF_VERSION/terraform-provisioner-local-exec /usr/local/bin
sudo cp -P terraform_$TF_VERSION/terraform-provisioner-file /usr/local/bin
sudo cp -P terraform_$TF_VERSION/terraform-provisioner-remote-exec /usr/local/bin
fi
fi
