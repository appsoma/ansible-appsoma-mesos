# **Appsoma Welder cluster deployment**


## Description


Deploy the [Appsoma Welder](https://github.com/appsoma/welder) app environment on a scalable Mesos cluster, with service 
discovery, monitoring, docker, Mesos frameworks for job and app management, and other cluster tools.

### What you get

Successfully running this playbook will create a cluster with:

* [Apache Mesos](http://mesos.apache.org/) with 1 or more master nodes and 1 or more slave nodes
* [Appsoma Welder](https://github.com/appsoma/welder) compute Application Management service
* [Appsoma Rhino](https://github.com/appsoma/rhino) batch processing framework to run jobs
* [Apache Zookeeper](https://zookeeper.apache.org/) to provide service registration and fault tolerance 
* [Mesosphere Marathon](https://github.com/mesosphere/marathon) service management framework registered with Mesos, and configured with [HAProxy](http://www.haproxy.org/) 
* [Apache Kafka](https://github.com/mesos/kafka) framework to create and run brokers
* [Apache Storm](https://github.com/mesosphere/storm-mesos) framework to run topologies
* [HAProxy](http://www.haproxy.org/) managed by [Gandalf](https://github.com/appsoma/gandalf) for service discovery and routing with support for wildcard DNS
* [Mesos-DNS](https://mesosphere.github.io/mesos-dns/docs/) for internal service discovery and DNS
* [Sensu](https://sensuapp.org) alerts for all nodes
* [Grafana](http://grafana.org/) metrics for all nodes
* [Docker](https://www.docker.com/) for containerized applications
* Python2.7, OpenJDK Java 6, 7, and 8, and NodeJS to run jobs and services locally
* And much more...
    
All nodes have access to an NFS-mounted data directory, shared across all masters and slaves, to share job data.  
A series of initial users created (see `cluster_vars/users.yml.template`) to use when running Welder jobs.

When using a cloud provider (for now, just Amazon EC2), you get dynamic access to your cloud, with node creation and management 

## Prerequisites

Ansible and Terraform will run from any host with network access to your cluster.  For a cloud provider, this requires internet access. 
For an intranet, your host will have to have access to the LAN (local or VPN) and SSH access.

Ansible can be installed on Ubuntu/Debian by adding the Ansible PPA repository:

	sudo apt-get install software-properties-common
	sudo apt-add-repository ppa:ansible/ansible
	sudo apt-get update
	sudo apt-get install ansible python-boto
	
Or on RH/Centos by using the [EPEL libary](http://fedoraproject.org/wiki/EPEL):

    sudo yum install ansible python-boto
	
Don't forget about Boto, the Amazon AWS client module for python.  The standard distro package should be sufficient.

Terraform can be installed by following the directions [here](https://www.terraform.io/intro/getting-started/install.html)

A convenience script (`install_ansible.sh`) is available in the repo.  This will install Ansible and Terraform on your system (using sudo)

# Installation

 
	git clone git@github.com:appsoma/ansible-appsoma-mesos.git
	cd ansible-appsoma-mesos

To configure your cluster, you'll have to create a directory with the name of your cluster: `cluster_vars/{{ cluster_name }}`.  
In this directory, you should create `cluster_vars/{{ cluster_name }}/required_vars.yml` and `cluster_vars/{{ cluster_name }}/users.yml`
from the templates in `cluster_vars/required_vars.yml.template` and `cluster_vars/users.yml.template`.  
The only absolute customization you must do is the `cluster_name` variable.  This will be the root name of all your instances.

To use HAProxy with SSL, set the flag in `required_vars.yml` and create a file called `cluster_vars/{{ cluster_name }}/haproxy.pem`


## How To install on EC2 

### What you'll need

This script will create 1 NFS server with an EBS data volume and a new VPC, as well as the master and slave nodes.  Make sure your subscription has enough resources available
To run with Amazon EC2, you'll have to collect an access credential (Access Key/Secret Key, or Access Key ID and Secret Access Key, either name might appear)
You'll also need to provide an RSA key pair.

You'll also need to select an AWS region and availability zone to install the cluster in.

If you use Route53 to manage a public domain name, you can assign DNS entries to your newly booted nodes. You'll need the name of the zone you want route53 to add new nodes to.
 
* Copy `cluster_vars/aws_secret_vars.yml.template` to `cluster_vars/{{ cluster_name }}/aws_secret_vars.yml` and edit the values to match your AWS account
    * Remember not to include the AWS keys in a git repo!
    * If you haven't already, copy `cluster_vars/required_vars.yml.template` and `cluster_vars/users.yml.template`
    * Set `cloud_provider: "ec2"` in `cluster_vars/{{ cluster_name }}/required_vars.yml`
    * Be sure to change the `ec2_region` and `ec2_zone` keys to match your information
    * If you want to use Route53 DNS, make sure `use_route53: true` and `route53_zone_id` is set to the ID of the hosted zone you will use on Route53.
    * Set the instance types, data volume size and type, and private lan subnets to your liking.  Remember these will cost you while running.

Next, you'll have to set up the EC2 environment.  If you have an existing Boto config (`/etc/boto.cfg`, `~/.boto`, or `~/.aws/credentials`), you can skip this

    source setup_amazon_env.bash
    
Now, test that you can access the Terraform dynamic inventory. 

    inventory/terraform.py --list

### Running

If your private key is in ~/.ssh, you don't need the `--private-key` option.  You may want to edit your user ssh config in `~/.ssh/config` or your system ssh config `/etc/ssh/ssh_config` to set `StrictHostKeyChecking no`. 
This will remove the warnings (which require you to type `yes`) when you connect to a brand new node on Amazon.
 
Now to run the playbook from scratch: 

    ansible-playbook --private-key ~/mykey.pem -i inventory/terraform.py manage_terraform_playbook.yml -e "cluster_name={{ cluster_name }}"
    ansible-playbook --private-key ~/mykey.pem -i inventory/terraform.py deploy_cluster_playbook.yml -e "cluster_name={{ cluster_name }}"

You can safely re-run these commands multiple times, in the event of an Amazon communication outage, or an error in variables.

If you edit `playbook_vars/users.yml`, you can update the entire cluster by running:
    
    ansible-playbook --private-key ~/mykey.pem -i inventory/terraform.py sync_users.yml -e "cluster_name={{ cluster_name }}"
    
This will add new users, and update existing users (and their passwords).  This fixed password management is the best solution short of a user directory system. (See [To do items](#to-do))

A convenience script to hide some of the Ansible argument complexity and AWS setup is available in `update_cluster.bash`, just run with the name of your cluster, and the name of the playbook yml file you want to use as arguments:
    
    update_cluster.bash {{ cluster_name }} deploy_cluster_playbook.yml
    
### Troubleshooting
* SSH errors
    * Make sure your SSH key has the correct permissions (`0600`).  Set `StrictHostKeyChecking no` in `/etc/ssh/ssh_config`
* Missing variable values
    * Check the `cluster_vars/{{ cluster_name }}` files, and ensure that you have customized the values for `aws_secret_vars.yml`, `required_vars.yml`, and `users.yml`
    * Rerun.  You can use the Ansible retry if it offers as well.
* Timeouts or `receive failed` messages
    * Custom repositories may not be responding (Docker, Mesosphere, Github. possibly core repos or cloud-served repos).
    * You may need to check the nodes internet connectivity or wait to rerun.  You can use the ansible retry if it offers as well.
* Timeouts or errors from AWS or Boto
    * Check that your `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables are set, or your boto.cfg is set up.
    * Check connectivity of the host you are running on to AWS (AWS may also suffer temporary outages too).
    * Rerun. You can use the Ansible retry if it offers as well.

    
## How To install with an existing cluster

### What you'll need

You'll need to construct an Ansible inventory file with a few attributes for the nodes in your cluster.  
A template with the required variables is in `cluster_vars/inventory.template` file.   This file can live anywhere, but we suggest `cluster_var/{{ cluster_name }}/inventory`

At least 3 nodes are required, one master, one service, and one slave.  You can also deploy with multiple master and slave nodes.

Your inventory file should look like this, with `mycluster` replaced with the cluster name.

    [mycluster_master]
    192.168.100.1   public_ip_address=192.168.100.1 public_dns_name=master_0.mycluster.mydomain.com private_ip_address=10.10.0.1 private_dns_name=master_0.internal system_name=master_0.internal short_name=master_0 type=master id=0 zoo_id=0
    
    [mycluster_service]
    192.168.100.254	public_ip_address=192.168.100.254 public_dns_name=service_0.mycluster.mydomain.com private_ip_address=10.10.0.254 private_dns_name=service_0.internal system_name=service_0.internal short_name=service_0 type=service id=0
    
    [mycluster_slave]
    192.168.100.2   public_ip_address=192.168.100.2 public_dns_name=slave_0.mydomain.com private_ip_address=10.10.0.2 private_dns_name=slave_0.internal system_name=slave_0 short_name=slave_0.internal type=slave_gp id=0

### Running

If your private key is in ~/.ssh, you don't need the `--private-key` option.  You may want to edit your user ssh config in `~/.ssh/config` or your system ssh config `/etc/ssh/ssh_config` to set `StrictHostKeyChecking no`. 
This will remove the warnings (which require you to type `yes`) when you connect to a brand new node on Amazon.
 
Now to run the playbook from scratch: 

    ansible-playbook --private-key ~/mykey.pem -i cluster_vars/{{ cluster_name }}/inventory create_cluster_playbook.yml -e "cluster_name={{ cluster_name }}"

You can safely re-run this command multiple times, in the event of an Amazon communication outage, or an error in variables.

If you edit `cluster_vars/{{ cluster_name }}/users.yml`, you can update the entire cluster by running:
    
    ansible-playbook --private-key ~/mykey.pem -i cluster_vars/{{ cluster_name }}/inventory sync_users.yml -e "cluster_name={{ cluster_name }}"

### Troubleshooting

* Missing variable values
    * Check the `cluster_vars/{{ cluster_name }}` files, and ensure that you have customized the values for `inventory`, `required_vars.yml`, and `users.yml`
    * Rerun.  You can use the Ansible retry if it offers as well.
* Timeouts or `receive failed` messages
    * Custom repositories may not be responding (Docker, Mesosphere, Github. possibly core repos or cloud-served repos).
    * You may need to check the nodes internet connectivity or wait to rerun.  You can use the Ansible retry if it offers as well.

-------------------------------

## Connecting to the cluster

You can ssh to your new cluster with user `ubuntu` and the private key you used for deployment.  If you use route53, nodes will be available at

* `master_*.{{ service_discovery_dns_suffix }}`
* `slave_*.{{ service_discovery_dns_suffix }}`
* `service_*.{{ service_discovery_dns_suffix }}`

Addtional SSH keys for user `ubuntu` can be set by setting `additional_ssh_keys` in cluster_vars/{{ cluster_name }}/required_vars.yml

The welder server will be listening on the master at the port specified in roles/ansible-welder/defaults/main.yml ( Defaults to `8890`)

The users you have defined in `cluster_vars/{{ cluster_name }}/users.yml` are available to log in to Welder, using the password defined.  These users do not have SSH access to the cluster.

The `welder_group:` section of `cluster_vars/{{ cluster_name }}/users.yml` defines a group that all Welder users will be a part of.

## Developing with Welder
The Welder source is checked out into `/opt/welder` on the master. The service can be started by running `service welder start` and `service welder-widgets start`. 
Logs for the service are saved in `/var/log/appsoma/welder.log`.

The Welder users can be configured for ssh login by setting an authorized key in `~/.ssh/authorized_keys`.  Each user's home directory has a scratch space on the data dir in `~/data`


## To Do

* Additional tools
* Supporting other clouds (GCE, OpenStack, etc.) via [Terraform](https://www.terraform.io/)
* Better utilization of docker
* Better cluster-wide user management (LDAP)
* Better cluster-wide file support (HDFS)

