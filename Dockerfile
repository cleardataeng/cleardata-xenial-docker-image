FROM ubuntu:16.04

ENV terraform_url=https://releases.hashicorp.com/terraform/0.9.1/terraform_0.9.1_linux_amd64.zip
ENV packer_url=https://releases.hashicorp.com/packer/0.12.3/packer_0.12.3_linux_amd64.zip

RUN \
    apt-get -q update && \
    DEBIAN_FRONTEND=noninteractive apt-get -q install -y \
                                   bind9-host \
                                   curl \
                                   dnsutils \
                                   iputils-ping \
                                   jq \
                                   openssh-client \
                                   python-paramiko \
                                   python-pip \
                                   python-pytest\
                                   python3-paramiko \
                                   python3-pip \
                                   python3-pytest \
                                   unzip \
                                   && \
    /usr/bin/pip --no-cache-dir install awscli awsrequests testinfra && \
    /usr/bin/pip3 --no-cache-dir install awscli awsrequests testinfra && \
    curl -o /root/terraform.zip $terraform_url && \
    curl -o /root/packer.zip $packer_url && \
    unzip /root/\*.zip -d /usr/local/bin && \
    rm -f /root/terraform /root/terraform.zip /root/packer /root/packer.zip
