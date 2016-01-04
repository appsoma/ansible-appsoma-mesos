FROM python:2.7.10

RUN apt-get update && apt-get install -y libpam0g-dev default-jre openjdk-7-jdk unzip python python-dev python-pip time

RUN pip install ansible
RUN sed -i.bak "/#\s*StrictHostKeyChecking */c StrictHostKeyChecking no" /etc/ssh/ssh_config
RUN sed -i.bak 's/ENV_SUPATH\s*PATH=\/usr/ENV_SUPATH PATH=\.:\/usr/' /etc/login.defs
RUN sed -i.bak 's/ENV_PATH\s*PATH=\/usr/ENV_PATH PATH=\.:\/usr/' /etc/login.defs
ADD https://releases.hashicorp.com/terraform/0.6.6/terraform_0.6.6_linux_amd64.zip  /tmp/terraform_0.6.6.zip
RUN unzip /tmp/terraform_0.6.6.zip -d /tmp/terraform_0.6.6
RUN cp -P /tmp/terraform_0.6.6/terraform /usr/local/bin
RUN cp -P /tmp/terraform_0.6.6/terraform-provider-aws /usr/local/bin
RUN cp -P /tmp/terraform_0.6.6/terraform-provider-google /usr/local/bin
RUN cp -P /tmp/terraform_0.6.6/terraform-provider-openstack /usr/local/bin
RUN cp -P /tmp/terraform_0.6.6/terraform-provisioner-local-exec /usr/local/bin
RUN cp -P /tmp/terraform_0.6.6/terraform-provisioner-file /usr/local/bin
RUN cp -P /tmp/terraform_0.6.6/terraform-provisioner-remote-exec /usr/local/bin


COPY . /ansible-appsoma-mesos

WORKDIR /ansible-appsoma-mesos