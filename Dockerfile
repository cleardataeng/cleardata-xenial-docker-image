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

# terraform 0.9 (default version)
ENV tf_ver=0.9.11
ENV tf_sha256=804d31cfa5fee5c2b1bff7816b64f0e26b1d766ac347c67091adccc2626e16f3
RUN curl -L -o terraform.zip https://releases.hashicorp.com/terraform/${tf_ver}/terraform_${tf_ver}_linux_amd64.zip && \
    echo "${tf_sha256} terraform.zip" > sha256sums && \
    sha256sum -c sha256sums --strict && \
    unzip terraform.zip && \
    install terraform /usr/local/bin/terraform-0.9 && \
    rm -rf terraform.zip terraform && \
    ln -sf teraform-0.9 /usr/local/bin/terraform

# terraform 0.11
ENV tf_ver=0.11.1
ENV tf_sha256=4e3d5e4c6a267e31e9f95d4c1b00f5a7be5a319698f0370825b459cb786e2f35
RUN curl -L -o terraform.zip https://releases.hashicorp.com/terraform/${tf_ver}/terraform_${tf_ver}_linux_amd64.zip && \
    echo "${tf_sha256} terraform.zip" > sha256sums && \
    sha256sum -c sha256sums --strict && \
    unzip terraform.zip && \
    install terraform /usr/local/bin/terraform-0.11 && \
    rm -rf terraform.zip terraform

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

# google-sdk
ADD google.key /tmp/google.key
RUN apt-key add < /tmp/google.key && \
    rm -f /tmp/google.key && \
    echo "deb http://packages.cloud.google.com/apt cloud-sdk-xenial main" > /etc/apt/sources.list.d/google-sdk.list && \
    apt-get -q update && \
    DEBIAN_FRONTEND=noninteractive apt-get -q install -y google-cloud-sdk && \
    gcloud config set core/disable_usage_reporting true && \
    gcloud config set component_manager/disable_update_check true

# gcr docker credential helper
ENV gcr_cred_helper_ver=1.4.1
ENV gcr_cred_helper_sha256=c4f51ff78c25e2bfef38af0f38c6966806e25da7c5e43092c53a4d467fea4743
RUN curl -L -o /root/gcrhelper.tar.gz https://github.com/GoogleCloudPlatform/docker-credential-gcr/releases/download/v${gcr_cred_helper_ver}/docker-credential-gcr_linux_amd64-${gcr_cred_helper_ver}.tar.gz && \
    echo "${gcr_cred_helper_sha256} gcrhelper.tar.gz" > /root/sha256sums && \
    (cd /root; sha256sum -c sha256sums --strict) && \
    tar zxvf /root/gcrhelper.tar.gz -C /root && \
    install /root/docker-credential-gcr /usr/local/bin

# ecs-cli
RUN curl -o /usr/local/bin/ecs-cli https://s3.amazonaws.com/amazon-ecs-cli/ecs-cli-linux-amd64-latest && \
    echo "$(curl -s https://s3.amazonaws.com/amazon-ecs-cli/ecs-cli-linux-amd64-latest.md5) /usr/local/bin/ecs-cli" | md5sum -c - && \
    chmod +x /usr/local/bin/ecs-cli

# cleanup
RUN rm -rf /root/* /tmp/* /google-cloud-sdk/.install/.backup
