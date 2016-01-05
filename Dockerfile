FROM python:2.7.11

ENV TF_VERSION 0.6.6
RUN apt-get update && apt-get install -y unzip time

RUN pip install ansible==1.9.4
RUN sed -i.bak "/#\s*StrictHostKeyChecking */c StrictHostKeyChecking no" /etc/ssh/ssh_config
RUN sed -i.bak 's/ENV_SUPATH\s*PATH=\/usr/ENV_SUPATH PATH=\.:\/usr/' /etc/login.defs
RUN sed -i.bak 's/ENV_PATH\s*PATH=\/usr/ENV_PATH PATH=\.:\/usr/' /etc/login.defs
ADD https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip  /tmp/terraform_${TF_VERSION}.zip
RUN unzip /tmp/terraform_${TF_VERSION}.zip -d /tmp/terraform_${TF_VERSION}
RUN cp -P /tmp/terraform_${TF_VERSION}/terraform /usr/local/bin
RUN cp -P /tmp/terraform_${TF_VERSION}/terraform-provider-aws /usr/local/bin
RUN cp -P /tmp/terraform_${TF_VERSION}/terraform-provider-google /usr/local/bin
RUN cp -P /tmp/terraform_${TF_VERSION}/terraform-provider-openstack /usr/local/bin
RUN cp -P /tmp/terraform_${TF_VERSION}/terraform-provisioner-local-exec /usr/local/bin
RUN cp -P /tmp/terraform_${TF_VERSION}/terraform-provisioner-file /usr/local/bin
RUN cp -P /tmp/terraform_${TF_VERSION}/terraform-provisioner-remote-exec /usr/local/bin
RUN rm -r /tmp/terraform_${TF_VERSION}.zip /tmp/terraform_${TF_VERSION}


COPY . /ansible-appsoma-mesos

WORKDIR /ansible-appsoma-mesos