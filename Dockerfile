FROM ubuntu:16.04

ENV tf_ver=0.9.11
ENV tf_sha256=804d31cfa5fee5c2b1bff7816b64f0e26b1d766ac347c67091adccc2626e16f3
ENV packer_ver=1.0.4
ENV packer_sha256=646da085cbcb8c666474d500a44d933df533cf4f1ff286193d67b51372c3c59e

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
    curl -o /root/terraform.zip https://releases.hashicorp.com/terraform/${tf_ver}/terraform_${tf_ver}_linux_amd64.zip && \
    curl -o /root/packer.zip https://releases.hashicorp.com/packer/${packer_ver}/packer_${packer_ver}_linux_amd64.zip && \
    echo "${packer_sha256} packer.zip" >> /root/sha256sums && \
    echo "${tf_sha256} terraform.zip" >> /root/sha256sums && \
    (cd /root; sha256sum -c sha256sums --strict) && \
    unzip /root/\*.zip -d /usr/local/bin && \
    rm -f /root/terraform /root/terraform.zip /root/packer /root/packer.zip

ADD aws-sudo/aws-sudo.sh /usr/local/bin/aws-sudo.sh
