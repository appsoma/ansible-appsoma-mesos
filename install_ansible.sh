#!/usr/bin/env bash
sudo apt-get install -y software-properties-common
sudo apt-add-repository -y ppa:ansible/ansible
sudo apt-get update
sudo apt-get install -y ansible unzip

wget https://dl.bintray.com/mitchellh/terraform/terraform_0.6.3_linux_amd64.zip -O terraform_0.6.3.zip
unzip terraform_0.6.3.zip -d terraform_0.6.3
sudo cp -P terraform_0.6.3/terraform /usr/local/bin
sudo cp -P terraform_0.6.3/terraform-provider-aws /usr/local/bin
sudo cp -P terraform_0.6.3/terraform-provider-google /usr/local/bin
sudo cp -P terraform_0.6.3/terraform-provider-openstack /usr/local/bin
sudo cp -P terraform_0.6.3/terraform-provisioner-local-exec /usr/local/bin


