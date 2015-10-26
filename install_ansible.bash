#!/usr/bin/env bash
sudo apt-get install -y software-properties-common
sudo apt-add-repository -y ppa:ansible/ansible
sudo apt-get update
sudo apt-get install -y ansible unzip

if [ -z "$1" ]; then
if [ "$1" != "local" ]; then
wget https://dl.bintray.com/mitchellh/terraform/terraform_0.6.4_linux_amd64.zip -O terraform_0.6.4.zip
unzip terraform_0.6.4.zip -d terraform_0.6.4
sudo cp -P terraform_0.6.4/terraform /usr/local/bin
sudo cp -P terraform_0.6.4/terraform-provider-aws /usr/local/bin
sudo cp -P terraform_0.6.4/terraform-provider-google /usr/local/bin
sudo cp -P terraform_0.6.4/terraform-provider-openstack /usr/local/bin
sudo cp -P terraform_0.6.4/terraform-provisioner-local-exec /usr/local/bin
fi
fi
