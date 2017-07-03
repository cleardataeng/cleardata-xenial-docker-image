FROM ubuntu:16.04

ENV terraform_url=https://releases.hashicorp.com/terraform/0.9.10/terraform_0.9.10_linux_amd64.zip
ENV packer_url=https://releases.hashicorp.com/packer/1.0.0/packer_1.0.0_linux_amd64.zip

RUN \
    apt-get -q update && \
    DEBIAN_FRONTEND=noninteractive apt-get -q install -y \
                                   apt-transport-https \
                                   bind9-host \
                                   ca-certificates \
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
                                   uuid-runtime \
                                   && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 8D81803C0EBFCD88 && \
    echo "deb https://download.docker.com/linux/ubuntu xenial stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get -q update && \
    DEBIAN_FRONTEND=noninteractive apt-get -q install -y docker-ce && \
    /usr/bin/pip --no-cache-dir install awscli awsrequests testinfra && \
    /usr/bin/pip3 --no-cache-dir install awscli awsrequests testinfra && \
    curl -o /root/terraform.zip $terraform_url && \
    curl -o /root/packer.zip $packer_url && \
    unzip /root/\*.zip -d /usr/local/bin && \
    rm -f /root/terraform /root/terraform.zip /root/packer /root/packer.zip
