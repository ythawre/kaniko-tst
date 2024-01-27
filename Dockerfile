FROM ubuntu:20.04

ENV export DOCKER_CONTENT_TRUST=1
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Singapore

# Install all required packages in a single RUN layer to reduce image size
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    curl \
    jq \
    unzip \
    git git-lfs \
    iputils-ping \
    gnupg \
    software-properties-common \
    lsb-release \
    ca-certificates \
    apt-transport-https \
    python3-pip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && chmod +x ./kubectl \
    && mv ./kubectl /usr/local/bin/kubectl \
    && curl -O https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \
    && bash ./get-helm-3 \
    && rm ./get-helm-3 \
    && curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - \
    && apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    && apt-get update \
    && apt-get install terraform -y \
    && pip3 install checkov ansible \
    && curl -s "https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh" | bash

# Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Add the Cloud SDK distribution URI as a package source and import the Google Cloud public key
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
# Import the Google Cloud public key
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    google-cloud-sdk \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Can be 'linux-x64', 'linux-arm64', 'linux-arm', 'rhel.6-x64'.
ENV TARGETARCH=linux-x64

WORKDIR /azp

COPY ./start.sh .
RUN chmod +x start.sh

ENTRYPOINT [ "./start.sh" ]