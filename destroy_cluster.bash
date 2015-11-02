#!/usr/bin/env bash
source setup_amazon_env.bash $1
cd terraform/$1/
terraform destroy
cd ../..
