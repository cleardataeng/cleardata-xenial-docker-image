FROM docker:18.06.1-ce as docker-source
FROM hashicorp/terraform:0.9.11 as terraform-0.9
FROM hashicorp/terraform:0.11.14 as terraform-0.11
FROM hashicorp/packer:1.4.4 as packer-source

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
                                   libssl-dev \
                                   openssh-client \
                                   python-paramiko \
                                   python-pip \
                                   python-pytest\
                                   python3-paramiko \
                                   python3-pip \
                                   python3-pytest \
                                   unzip \
                                   uuid-runtime

# install and setup all of the apt keys / repos in the apt subdir
# this way, a single apt-get update pulls in all of the external repos
ADD apt/* /tmp/apt/
RUN for i in /tmp/apt/*.key; do apt-key add $i; done && \
    cp /tmp/apt/*.list /etc/apt/sources.list.d && \
    rm -rf /tmp/apt && \
    apt-get update

# common python modules
RUN /usr/bin/pip --no-cache-dir install awscli awsrequests testinfra && \
    /usr/bin/pip3 --no-cache-dir install awscli awsrequests testinfra

# docker
COPY --from-docker-source /usr/local/bin/docker /usr/local/bin/docker

# terraform 0.9 (default version)
COPY --from=terraform-0.9 /bin/terraform /usr/local/bin/terraform
RUN ln -s /usr/local/bin/terraform /usr/local/bin/terraform-0.9

# terraform 0.11
COPY --from=terraform-0.11 /bin/terraform /usr/local/bin/terraform-0.11

# packer
COPY --from=packer-source /bin/packer /usr/local/bin/packer

# go config
ENV GOPATH=/go
RUN mkdir ${GOPATH} && \
    chmod 0777 ${GOPATH}

# aws-sudo
ADD aws-sudo/aws-sudo.sh /usr/local/bin/aws-sudo.sh

# google-sdk
RUN DEBIAN_FRONTEND=noninteractive apt-get -q install -y google-cloud-sdk \
                                                         kubectl && \
    gcloud config set core/disable_usage_reporting true && \
    gcloud config set component_manager/disable_update_check true

# gcr docker credential helper
ENV gcr_cred_helper_ver=1.4.3
ENV gcr_cred_helper_sha256=0630f744a5f42bf14e5986c959f32c5770a1f32d50ba055bd98353c7d18292d3
RUN curl -L -o /root/gcrhelper.tar.gz https://github.com/GoogleCloudPlatform/docker-credential-gcr/releases/download/v${gcr_cred_helper_ver}-static/docker-credential-gcr_linux_amd64-${gcr_cred_helper_ver}.tar.gz && \
    echo "${gcr_cred_helper_sha256} gcrhelper.tar.gz" > /root/sha256sums && \
    (cd /root; sha256sum -c sha256sums --strict) && \
    tar zxvf /root/gcrhelper.tar.gz -C /root && \
    install /root/docker-credential-gcr /usr/local/bin

# ecs-cli
RUN curl -o /usr/local/bin/ecs-cli https://s3.amazonaws.com/amazon-ecs-cli/ecs-cli-linux-amd64-latest && \
    echo "$(curl -s https://s3.amazonaws.com/amazon-ecs-cli/ecs-cli-linux-amd64-latest.md5) /usr/local/bin/ecs-cli" | md5sum -c - && \
    chmod +x /usr/local/bin/ecs-cli

# node 9.x
RUN echo "send-metrics = false" > /etc/npmrc && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y nodejs yarn && \
    npm install npm --global

# cleanup
RUN rm -rf /root/* /tmp/* /google-cloud-sdk/.install/.backup
