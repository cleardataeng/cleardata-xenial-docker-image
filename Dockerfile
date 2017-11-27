FROM ubuntu:16.04

# common initial setup
RUN apt-get -q update && \
    DEBIAN_FRONTEND=noninteractive apt-get -q install -y \
                                   apt-transport-https \
                                   bind9-host \
                                   ca-certificates \
                                   curl \
                                   dnsutils \
                                   golang \
                                   iputils-ping \
                                   jq \
                                   npm \
                                   openssh-client \
                                   python-paramiko \
                                   python-pip \
                                   python-pytest\
                                   python3-paramiko \
                                   python3-pip \
                                   python3-pytest \
                                   unzip \
                                   uuid-runtime

# common python modules
RUN /usr/bin/pip --no-cache-dir install awscli awsrequests testinfra && \
    /usr/bin/pip3 --no-cache-dir install awscli awsrequests testinfra

# docker
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 8D81803C0EBFCD88 && \
    echo "deb https://download.docker.com/linux/ubuntu xenial stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -q install -y docker-ce

# terraform
ENV tf_ver=0.9.11
ENV tf_sha256=804d31cfa5fee5c2b1bff7816b64f0e26b1d766ac347c67091adccc2626e16f3
RUN curl -L -o /root/terraform.zip https://releases.hashicorp.com/terraform/${tf_ver}/terraform_${tf_ver}_linux_amd64.zip && \
    echo "${tf_sha256} terraform.zip" > /root/sha256sums && \
    (cd /root; sha256sum -c sha256sums --strict) &&\
    unzip /root/terraform.zip -d /usr/local/bin

# packer
ENV packer_ver=1.0.4
ENV packer_sha256=646da085cbcb8c666474d500a44d933df533cf4f1ff286193d67b51372c3c59e
RUN curl -L -o /root/packer.zip https://releases.hashicorp.com/packer/${packer_ver}/packer_${packer_ver}_linux_amd64.zip && \
    echo "${packer_sha256} packer.zip" > /root/sha256sums && \
    (cd /root; sha256sum -c sha256sums --strict) && \
    unzip /root/packer.zip -d /usr/local/bin

# go config
ENV GOPATH=/go
RUN mkdir ${GOPATH} && \
    chmod 0777 ${GOPATH}

# aws-sudo
ADD aws-sudo/aws-sudo.sh /usr/local/bin/aws-sudo.sh

# cleanup
RUN rm -rf /root/* /tmp/*
