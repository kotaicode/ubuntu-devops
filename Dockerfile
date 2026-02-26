FROM ubuntu:24.04
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
  apache2-utils \
  apt-transport-https \
  build-essential \
  ca-certificates \
  curl \
  dnsutils \
  git \
  gnupg \
  jq \
  libffi-dev \
  libssl-dev \
  lsb-release \
  magic-wormhole \
  make \
  mysql-client \
  nano \
  postgresql-client \
  python3-all-dev \
  python3-pip \
  python3-setuptools \
  python3-venv \
  python3.6 \
  redis-tools \
  ruby-full \
  silversearcher-ag \
  ssh-client \
  tmux \
  unzip \
  vim \
  wget \
  yamllint \
  inetutils-ping \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Apply security updates (e.g. libgnutls30t64 CVE-2025-14831)
RUN apt-get update && apt-get upgrade -y --no-install-recommends \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# install yq
ENV YQ_VERSION="4.52.4"
RUN wget https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_amd64 -O /usr/bin/yq &&\
    chmod +x /usr/bin/yq

# AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && unzip awscliv2.zip && ./aws/install

# Azure CLI (use venv; upgrade pip to address CVE-2025-8869)
RUN python3 -m venv /opt/azure-cli && \
    . /opt/azure-cli/bin/activate && \
    pip install --no-cache-dir --upgrade 'pip>=25.3' && \
    pip install --no-cache-dir azure-cli && \
    ln -s /opt/azure-cli/bin/az /usr/local/bin/az

# GCloud SDK
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg && \
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
apt-get update && apt-get install  -y --no-install-recommends google-cloud-cli

# install go (single RUN so tar sees the downloaded file; use 1.22 LTS with security fixes)
ENV GO_VERSION="1.22.4"
RUN wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz -O /tmp/go.tar.gz && \
    tar -C /usr/local -xzf /tmp/go.tar.gz && \
    rm /tmp/go.tar.gz
ENV GOROOT=/usr/local/go
ENV PATH=$PATH:/usr/local/go/bin

# RABBITMQ tooling
ENV RABBITMQ_ADMIN_VERSION="3.7.15"
RUN wget https://raw.githubusercontent.com/rabbitmq/rabbitmq-management/v${RABBITMQ_ADMIN_VERSION}/bin/rabbitmqadmin -O ~/rabbitmqadmin
RUN chmod +x ~/rabbitmqadmin
RUN mv ~/rabbitmqadmin /usr/bin/

#install rabtap
ENV RABTAP_VERSION="1.39.1"
RUN wget https://github.com/jandelgado/rabtap/releases/download/v${RABTAP_VERSION}/rabtap_${RABTAP_VERSION}_linux_amd64.tar.gz && \
    tar -xzf rabtap_${RABTAP_VERSION}_linux_amd64.tar.gz && \
    mv rabtap /usr/bin/ && \
    rm rabtap_${RABTAP_VERSION}_linux_amd64.tar.gz

# install terraform (newer release built with patched Go)
ENV TERRAFORM_VERSION="1.12.1"
RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -O /tmp/terraform.zip && \
    unzip /tmp/terraform.zip -d /tmp && \
    mv /tmp/terraform /usr/bin/ && \
    rm /tmp/terraform.zip

# Vim plugins
# pathogen
RUN mkdir -p $HOME/.vim/autoload $HOME/.vim/bundle && \
  curl -LSso $HOME/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
COPY vimrc /root/.vimrc
# Sensible
RUN git clone https://github.com/tpope/vim-sensible.git $HOME/.vim/bundle/vim-sensible && \
# Dockerfile syntax & snippet plugin
    git clone https://github.com/ekalinin/Dockerfile.vim.git $HOME/.vim/bundle/Dockerfile && \
# Vim airline
    git clone https://github.com/bling/vim-airline $HOME/.vim/bundle/vim-airline && \
# CtrlP
    git clone https://github.com/kien/ctrlp.vim.git $HOME/.vim/bundle/ctrlp.vim && \
# vim-go
    git clone https://github.com/fatih/vim-go.git ~/.vim/bundle/vim-go

# mongo client
#RUN wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | apt-key add -
#RUN echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-5.0.list
#RUN apt-get update && apt-get install -y mongodb-mongosh

# nodejs & yarn (Node 22 LTS ships with newer npm and patched deps)
RUN curl -sL https://deb.nodesource.com/setup_22.x  | bash -
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor -o /usr/share/keyrings/yarn.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/yarn.gpg] https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get -y install nodejs yarn \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# jsonlint (global); npm update -g to pull in patched transitive deps where possible
RUN npm install jsonlint -g && npm update -g

# install kubectl (newer versions with patched Go stdlib)
ENV KUBECTL_VERSIONS="1.30.0 1.31.0 1.32.0"
ENV KUBECTL_INSTALL_DIR=/usr/local/bin
COPY install-kubectl.sh /tmp/install-kubectl.sh
RUN /tmp/install-kubectl.sh
ENV PATH=$PATH:$KUBECTL_INSTALL_DIR
RUN echo 'source k8s_aliases' >> ~/.bashrc

#mssql-cli
#RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
#    && curl -o /etc/apt/sources.list.d/microsoft.list https://packages.microsoft.com/config/ubuntu/20.04/prod.list
#
#RUN apt-get update && apt-get -y install mssql-tools \
#  && apt-get clean \
#  && rm -rf /var/lib/apt/lists/*
